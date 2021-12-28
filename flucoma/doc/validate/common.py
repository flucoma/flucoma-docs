# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).


import logging
from functools import partial 

from schema import Schema, Optional,Or,Use

from ..logger import add_context 

not_yet_documented = """

.. warning:: Not yet documented 

"""

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
    def step(acc,next,lookup):
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

def undocumented(x): 
    """return the built in not documented tag string"""
    logging.warning('not yet documented')#,extra={'context':scope})
    return not_yet_documented

def Fallbacks(keys,lookup):
        """
        Composes the series of fallbacks above into a Schema that will use valid content, or try a lookup, or tag undocumented as a last resort 
        """
        return Or(
            Use(hasContent),
            Use(partial(tryLookup,keys=keys,lookup=lookup)),
            Use(undocumented)        
        )


def PermissveSchema(schema): 
    '''
    Make a Schema cheerfully permissive by passing through any extra keys it encounters. The code for this is simple enough but distracting if done inline. Note that this is totally assuming that the schema is a dict, which is true for our purposes here but narrower than what the library actually affords
    '''
    return(Schema({
            **schema, # all the original stuff
            **{Optional(object):object} # _maybe_ other things, in which case just pass
        }))

class RecordContext: 
    '''
    Slightly hacky wrapper for a schema.Schema so that we can set the logging context as schema walks through a tree of objects
    
    @todo a better name would perhaps help my aching soul
    '''
    def __init__(self, schema, *args):
        self.schema = schema
        self.context = args
        
    def validate(self, *args): 
        with add_context(self.context): 
            logging.debug(f'validating {self.context}')
            return Schema(self.schema).validate(*args)
