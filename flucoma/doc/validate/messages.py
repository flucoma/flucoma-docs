# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from .common import PermissveSchema, not_yet_documented, RecordContext
from schema import Schema, Or, Optional, Use, SchemaError
from functools import partial, reduce
from ..defaults import DefaultControlDocs, DefaultMessageDocs
import logging


def validate_messages(generated_message_data, human_message_data,**kwargs):
    """
    validate the 'messages' block of human made doc against its canoncial, generated counterpart. If things are missing, try and find a default placeholder for that message, otherwise tag as undocumented. 
    
    We use the schema library for validation, whose natural inclination is to bail when stuff is missing. However, we just want to detect it and, if all else fails, tag it. So some mild acrobatics are invoked, with only petty crimes committed.  
    """
    lookup = kwargs.pop('defaults_lookup', DefaultMessageDocs)
    logging.debug('validating messages')
    null_arg = { 'name':None, 'description':None }
    
    human_message_data = human_message_data or {}
    
    def NullMessage(num_args):
        """
        A message block with no content: 
        
        ```
        {
            'description': None, 
            'args':[
                {
                    'name': None, 'description':None
                }   # as many times are there are arguments for this message         
            ]
        }
        ```
        """
        return  {'description': None, 'args':[null_arg] * num_args}
    
    def hasContent(x):
        """
        If x has content (assuming it's a str, dict or array, which is safe here), return x else raise SchemaError to fallback to next option
        """
        if not len(x):
            raise SchemaError
        return x
         
    def tryLookup(x, keys):
        """
        see if there is an entry for `keys` in the lookup table passed to the parent function. `keys` is an array of dict keys to be descended through, e.g. `['foo','bar','description']` would query `lookup` for 
        {
            'foo':{'bar'{'description':<whatever>}}
        }
        """
        def step(acc,next):
            """
            Function used by `reduce` to step through `keys`. 
            
            Could be a lambda, but being able to print in debugging is handy 
            """
            # print(acc,next)
            return acc[next]

        try: 
            return reduce(step, keys, lookup) #mild code crime
        except: 
            raise SchemaError # lookup failed, fallback to next option 
    
    def uncdocumented(x): 
        """return the built in not documented tag string"""
        logging.warning('not yet documented')#,extra={'context':scope})
        return not_yet_documented
    
    def fill_args(x,length):
        """
        when validating the array of message arguments, we need the input to be the required length already, so if there are too many then trim, or not enough then pad with None-d-out objects, before then validating against schema
        """
        if not x: x = []
        if len(x) > length: x = x[:length]
        if len(x) < length: x += [null_arg] * (length - len(x))
    
        ret =  Schema([{
            Optional('name', default = None):object,
            Optional('description', default = None):object
        }] * length).validate(x)

        return ret

    def Fallbacks(keys):
        """
        Composes the series of fallbacks above into a Schema that will use valid content, or try a lookup, or tag undocumented as a last resort 
        """
        return Or(
            Use(hasContent),
            Use(partial(tryLookup,keys=keys)),
            Use(uncdocumented)        
        )
    
    '''
    In our first pass, any expected parts of the structure are filled in with null entries (the expected parts of the structure are supplied by generated_message_data)
    '''
    s_first = PermissveSchema({
        Optional(d['name'], default = NullMessage(len(d['args']))): {
            Optional('description', default = None): object,
            Optional('args', default = []): Use(partial(
                                                  fill_args,length=len(d['args']
                                            )))
        }
        for d in generated_message_data
    }).validate(human_message_data)
    
    '''
    In our second pass, we now know that there is *an* entity in all the expected places, so we can use our `Fallbacks` sequence to see if it has actual content, and try for a default otherwise, issuing a not-documented tag if that fails 
    '''
    s_second = PermissveSchema({
        d['name']: RecordContext({
            'description': RecordContext(Fallbacks([d['name'],'description']), 'description'), 
            'args':[RecordContext(Or(
                {
                    'name': Fallbacks([d['name'],'args','name']),
                    'description':Fallbacks([d['name'],'args','description']) 
                },
                {
                    'name':Use(uncdocumented),
                    'description':Use(uncdocumented)
                }),'argument'
            )] * len(d['args'])
        },d['name'])
        for d in generated_message_data
    })
    return s_second.validate(s_first)
