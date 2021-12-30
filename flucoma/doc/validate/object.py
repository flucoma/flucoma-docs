# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).


import logging 

from schema import Schema, Optional, Use

from .controls import validate_controls
from .messages import validate_messages

from ..logger import add_context

"""
Given some machine generated documentation (in a dict), and some human documentation (in a dict), we use the structure of the former to check over the completeness of the latter, using defaults where we can, or issuing warnings otherwise 
"""

human_schema = {
    # Top level schema stub for the human made documentation. This gets 
    # augmented by generated schemas for the controls and messages 
    'digest': str,
    'sc-categories': str,
    'sc-related': str,
    'description': str,
    Optional('discussion'): str,
    Optional('output'): str,
    Optional('sc-code'): str,
    Optional('see-also',   default=''): Use(str),
    Optional('parameters', default = {}):object,
    Optional('messages',   default = {}): object,
    Optional(object): object #pass through any extras
}

def validate_object(generated_data, human_data, **kwargs):
    """
    Given some generated doc data for a FluCoMa object, and its human made counterpart, check the completeness of the latter against the former (which is canonical). For any missing stuff, we use a default placeholder if available, else tag it as undocumented 
    """

    with add_context([generated_data['name']]):
        
        logging.info(f"valdating data for {generated_data['name']}")
        
        human_data =  Schema(human_schema).validate(human_data)
            
        human_data['parameters'] = validate_controls( 
            generated_data['parameters'], human_data['parameters'],**kwargs
        ) 
        
        human_data['messages'] = validate_messages(
            generated_data['messages'], human_data['messages'],**kwargs
        )
        
        return generated_data, human_data
    
   
