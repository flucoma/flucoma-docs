# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import argparse
from pathlib import Path
import yaml
import json
import locale 
import pickle
import logging 
import importlib
import sys 
from flucoma.doc import render
from flucoma.doc.validate.object import validate_object, merge_object
from flucoma.doc.legacy.adaptor import make_it_like_it_was
from pprint import pprint

from flucoma.doc.logger import ContextFilter

def load_generated_data(client_file):
        logging.debug(f'opening {client_file}')
        
        with open(client_file.resolve()) as f:
            data = json.load(f)
            data['name'] = client_file.stem 
            return data 

def load_human_data(client_file,args):
    
    yamldir = args.yaml_path
    human_data = {}
    human_data_path = yamldir / (client_file.stem + '.yaml')    
    logging.debug(f'opening {human_data_path}')
    if(human_data_path.exists()):
        with open(human_data_path.resolve()) as f:
            return yaml.load(f, Loader=yaml.FullLoader)
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

def main(passed_args):
    """
    Set default locale, in case it hasn't been, otherwise we can't read text
    """
    locale.setlocale(locale.LC_ALL,'')
    
    formatter = logging.Formatter('{levelname}: {context} - {message}', style='{')    
    ch = logging.StreamHandler()
    ch.setLevel(logging.WARNING)
    ch.setFormatter(formatter)
    logging.getLogger().addFilter(ContextFilter())
    logging.getLogger().addHandler(ch)    
    
    
    logging.debug(f'raw arguments {passed_args}')
    
    parser = argparse.ArgumentParser(
        description='Generate FluCoMa documentation for a given host, using input JSON and YAML data and a jinja template')

    parser.add_argument('host', choices=['max','pd','cli','sc'])

    parser.add_argument('json_path', type=Path,
                        help='Path to generated JSON client data')

    parser.add_argument('yaml_path', type=Path,
                        help='Path to human made YAML client documentation')

    parser.add_argument('output_path', type=Path,
                        help='Path to write output files to')

    parser.add_argument('template_path', type=Path,
                        help='Path containing Jinja template(s)')

    args = parser.parse_args(passed_args)
    
    driver = importlib.import_module('.driver', f'flucoma.doc.{args.host}')
    host_settings = driver.settings 

    clients = list(args.json_path.glob(host_settings['glob']))
    args.output_path.mkdir(exist_ok=True)
    
    logging.debug(f'passed options: {args}')

    index = {
        c.stem : host_settings['transform'](c.stem, 
                merge_object(
                    *validate_object(
                        load_generated_data(c), 
                        load_human_data(c, args),
                    **host_settings)
                )
            ) for c in clients     
    }    

    for c in index: 
        render.client(c, index, args, host_settings)

    if host_settings['post']: host_settings['post'](index,args)

    topics = list(Path('topics/').resolve().glob('*.yaml'))
    for t in topics: 
      render.topic(load_topic_data(t),index, args, host_settings)

if __name__ == '__main__':
    main(sys.argv[1:])
