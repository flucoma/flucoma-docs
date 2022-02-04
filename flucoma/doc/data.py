# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import logging
import json 
import yaml
from flucoma.doc.rst import parse_object

def load_generated_data(client_file):
        logging.debug(f'opening {client_file}')
        
        with open(client_file.resolve()) as f:
            data = json.load(f)
            data['name'] = client_file.stem 
            return data 

def load_human_data(client_file,args):
    
    docs_dir = args.doc_path
    human_data_path = docs_dir / (client_file.stem + '.rst')    
    logging.debug(f'opening {human_data_path}')
    if(human_data_path.exists()):
        with open(human_data_path.resolve()) as f:
            return parse_object.parse(f.read())
    else:
        logging.warning(f'No human documentation found for {client_file.stem}')
        return None

def load_topic_data(topic):
    logging.debug(f'opening {topic}')        
    if(topic.exists()):
        with open(topic.resolve()) as f:
             data = yaml.load(f, Loader=yaml.FullLoader)
             data['name'] = topic.stem
             return data
    else:         
        raise NameError(f'{topic} not found')
