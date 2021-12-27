# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from schema import Schema, Optional 

from ..logger import add_context 
import logging

not_yet_documented = """

.. warning:: Not yet documented 

"""

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
