# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import json

from docutils import nodes

from flucoma.doc.rst.html import FluidHTMLWriter, rst_filter
from .. transformers import default_transform
from .defaults import defaults

def buffer_reference_role(role, rawtext, text, lineno, inliner,
                           options={}, content=[]):
    return 'buffer~'

def max_visit_flucoma_reference(self, node, data, transform_name):
    if transform_name:
        if(node.astext()) in data:
            name = max_object_namer(data[node.astext()]) 
        else: 
            name = f'Unresolved lookup ({node.astext()})'
    else: 
        name = node.astext()
    
    node[:] = [nodes.raw('',name, format='html')]
    self.body.append(self.starttag(node, 'o'))
    
def max_depart_flucoma_reference(self, node, data):
    self.body.append('</o>')
    
def max_object_namer(data):    
    tilde = '~' if not data['input_type'] == 'control' else ''
    return f"fluid.{data['client_name'].lower()}{tilde}"    

def max_type_map(type):       
    
    return {
        'float':'float64',
        'long': 'int',
        'buffer':'symbol',
        'integer': 'int',
        'string': 'symbol',
        'enum':'int', 
        'fft': 'int',
        'dataset':'symbol',
        'labelset':'symbol',
        'choices':'symbol'
    }[type]


def transform_data(client, data):
    return default_transform(client, data)

def max_jinja_parameter_link(name,data):
    return f'<at>{name.lower()}</at>'

def write_max_indices(idx,program_args):
    
    path = program_args.output_path / '../interfaces'
    path.mkdir(exist_ok=True)
    
    maxdb_objs = {'maxdb':{'externals':{}}}
    qlookup = {}
    
    for client,data in idx.items():

        maxname = max_object_namer(data)
        
        if data.get('species','') == 'data':
            maxdb_objs['maxdb']['externals'][maxname]={
                'object':'fluid.libmanipulation',
                'package':'Fluid Corpus Manipulation'
            }
        
        qlookup[maxname] = {
            'digest': data['digest'],'category':['Fluid Corpus Manuipulation']
        }
    
    maxdbfile = path / 'max.db.json'
    with open(maxdbfile,'w', encoding='utf-8') as f:
        json.dump(maxdb_objs,f,sort_keys=True, indent=4)
    qlookup_file = path / 'flucoma-obj-qlookup.json'
    with open(qlookup_file,'w', encoding='utf-8') as f: 
        json.dump(qlookup,f,sort_keys=True, indent=4)


settings = {   
    'namer':max_object_namer,     
    'template': 'maxref.xml',
    'extension': 'maxref.xml',
    'types': max_type_map,
    'glob': '**/*.json', 
    'parameter_link': max_jinja_parameter_link, 
    'code_block': lambda p: f"<m>{p.lower()}</m>", 
    'writer': FluidHTMLWriter, 
    'rst_render': rst_filter,
    'write_cross_ref': (max_visit_flucoma_reference,    
                        max_depart_flucoma_reference),
    'topic_extension': 'maxvig.xml', 
    'topic_subdir': 'vignettes',
    'client_subdir': '',
    'topic_template':'maxvig.xml',
    'transform': transform_data, 
    'post': write_max_indices, 
    'defaults': defaults, 
    'buffer-string':'<o>buffer~</o>'
}
