# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import logging

def merge_object(generated_data,human_data):
    """
    Given some generated doc data for a FluCoMa object, and its human made counterpart, merge these into a unified data structure for use in doc generation
    """
    
    logging.info(f"merging {generated_data['name']}")
    
    def noParamsMessages(data):
        return filter(
            lambda x: x[0] != 'parameters' and x[0] != 'messages', 
            data.items()
        )    

    object_data = {# the stuff that isn't parameters or messages
        **{k:v for k,v in noParamsMessages(generated_data)},
        **{k:v for k,v in noParamsMessages(human_data)}
    }
    
    object_data['parameters'] = [{
        **p, 
        **human_data['parameters'][p['name']]
    } for p in generated_data['parameters']]
    
    object_data['messages'] = [{
        **p, 
        **human_data['messages'][p['name']]
    } for p in generated_data['messages']]
    
    return object_data   
