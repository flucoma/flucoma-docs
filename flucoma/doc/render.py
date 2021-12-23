# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from jinja2 import Template, Environment, PackageLoader, FileSystemLoader, select_autoescape, Markup

import flucoma.doc.rst.references
from flucoma.doc.rst.html import rst_filter
import logging
from functools import partial
from pathlib import Path

def type_map(x,namer):
    try: 
        return namer(x)
    except KeyError: 
        return f'Unknown Type ({x})'

def setup_jinja(client_index, args, driver):
    e = Environment(
        loader = FileSystemLoader([args.template_path]),
        autoescape=select_autoescape(['html','xml']),
        trim_blocks=True, lstrip_blocks=True
    )
    """
    Custom jinja filters and tests
    """
    e.filters['rst'] = partial(rst_filter,data=client_index, driver=driver)
    e.filters['as_host_object_name'] = lambda x: driver['namer'](client_index[x]) if x in client_index else f'Unresolved lookup ({x})'
    e.filters['typename'] = partial(type_map, namer=driver['types'])
    e.filters['constraints'] = lambda x,y,z: ''     
    e.filters['lookup'] = lambda x: client_index[x] if x in client_index else ''       
    e.tests['incli'] = lambda s: s.lower().startswith('buf')
    
    return e 
    
def client(client, client_index, args, driver):    
    template_path = args.template_path
    outputdir = args.output_path
    client_data = client_index[client]
    ofile = outputdir / f"{driver['namer'](client_data)}.{driver['extension']}"
    env = setup_jinja(client_index, args, driver)    
    template = env.get_template(driver['template'])
    logging.info(f'{client}: Making {ofile}')
    with open(ofile,'w') as f:
        f.write(template.render(client_data))            
        
    return client_data; 

def topic(topic_data,client_index,args,driver):
    
    outputdir = args.output_path
    
    # ofile = outputdir / '{}.{}'.format(Path(driver['topic_subdir']) / Path(topic_file.stem),driver['topic_extension'])    
    
    ofile = outputdir / f"{Path(driver['topic_subdir']) /topic_data['name']}.{driver['topic_extension']}"
    
    (outputdir / Path(driver['topic_subdir'])).mkdir(exist_ok=True)
        
    env = setup_jinja(client_index, args, driver) 
    template = env.get_template(driver['topic_template'])
    logging.info(f"{topic_data['name']}: Making {ofile}")
    with open(ofile,'w') as f:
        f.write(template.render(
            title=topic_data['title'],
            digest=topic_data['digest'],
            description=topic_data['description'],
        ))
