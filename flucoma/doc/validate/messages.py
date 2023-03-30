# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import logging
from functools import partial

from schema import Schema, Or, Optional, Use

from ..defaults import DefaultMessageDocs
from .common import PermissveSchema, RecordContext, Fallbacks, undocumented


def validate_messages(generated_message_data, human_message_data,**kwargs):
    """
    validate the 'messages' block of human made doc against its canoncial, generated counterpart. If things are missing, try and find a default placeholder for that message, otherwise tag as undocumented. 
    
    We use the schema library for validation, whose natural inclination is to bail when stuff is missing. However, we just want to detect it and, if all else fails, tag it. So some mild acrobatics are invoked, with only petty crimes committed.  
    """
    
    lookup = {
                **DefaultMessageDocs,    
                **(kwargs.get('defaults',{}) or {}).get('messages',{})
    }
    
    
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
    
    '''
    In our first pass, any expected parts of the structure are filled in with null entries (the expected parts of the structure are supplied by generated_message_data)
    '''
    s_first = PermissveSchema({
        Optional(d['name'], default = NullMessage(len(d['args']))): {
            Optional('description', default = None): object,
            Optional('args',default = [null_arg] * len(d['args'])): Use(
                            partial(fill_args,length=len(d['args'])))
        }
        for d in generated_message_data
    }).validate(human_message_data)
    
    '''
    In our second pass, we now know that there is *an* entity in all the expected places, so we can use our `Fallbacks` sequence to see if it has actual content, and try for a default otherwise, issuing a not-documented tag if that fails 
    '''
    s_second = PermissveSchema({
        d['name']: RecordContext({
            'description': RecordContext(
                            Fallbacks(
                                [d['name'],'description'], 
                                lookup), 
                            'description'), 
            'args':[RecordContext(Or(
                {
                    'name': RecordContext(Fallbacks(
                                    [d['name'],'args',i ,'name'], 
                                    lookup,undocumented_string='unamed_arg'),
                            'name'),
                    'description':RecordContext(Fallbacks(
                                    [d['name'],'args',i, 'description'],
                                    lookup),
                                'description')
                },
                {
                    'name':Use(undocumented),
                    'description':Use(undocumented)
                }),f'argument {i}'
            ) for i,_ in enumerate(d['args'])] 
        },d['name'])
        for d in generated_message_data
    })
    return s_second.validate(s_first)
