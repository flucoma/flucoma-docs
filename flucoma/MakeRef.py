# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import argparse
from pathlib import Path
import locale 
import logging 
import importlib
import sys 

from flucoma.doc import render
from flucoma.doc.data import load_generated_data, load_human_data, load_topic_data
from flucoma.doc.validate.object import validate_object
from flucoma.doc.merge import merge_object
from flucoma.doc.logger import ContextFilter

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
    
    fh = logging.FileHandler('flucoma-makeref.log',mode='w')
    fh.setLevel(logging.WARNING)
    fh.setFormatter(formatter)
    logging.getLogger().addHandler(fh)    
    
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
    
    parser.add_argument('--quiet',help='surpress stderr output', action="store_true")
                            
    args = parser.parse_args(passed_args)
    
    if(args.quiet):
        logging.getLogger().removeHandler(ch)
    
    driver = importlib.import_module('.driver', f'flucoma.doc.{args.host}')
    host_settings = driver.settings 

    glob_filter = host_settings.get('glob_filter',lambda x: True)
    glob_string = host_settings.get('glob_glob','**/*.json')
    clients = filter(glob_filter,    
                                args.json_path.glob(glob_string))
        
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
    
    if host_settings.get('template'): 
        for c in index: 
            render.client(c, index, args, host_settings)

    if host_settings.get('post'): 
            host_settings['post'](index,args)

    if host_settings.get('topic_template'):
        topics = list(Path('topics/').resolve().glob('*.yaml'))
        for t in topics: 
          render.topic(load_topic_data(t),index, args, host_settings)

if __name__ == '__main__':
    main(sys.argv[1:])
