# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from docutils import nodes
from collections import OrderedDict
from ..transformers import tidy_split, filter_fixed_controls
from flucoma.doc.rst.scdoc import SCDocWriter,rst_filter
from .defaults import defaults

def buffer_reference_role(role, rawtext, text, lineno, inliner,
                           options={}, content=[]):
    return 'array'

def sc_visit_flucoma_reference(self, node, data, transform_name):
    if transform_name:
        if(node.astext()) in data:            
            name = sc_object_namer(data[node.astext()]) 
        else: 
            name = f'Unresolved lookup ({node.astext()})'
    else: 
        name = node.astext()

    self.body.append(f"LINK::Classes/{name}::")
    raise nodes.SkipNode 
    
def sc_depart_flucoma_reference(self, node, data):
    pass

def sc_object_namer(data):    
    return f"Fluid{data['client_name']}"    

def sc_jinja_parameter_link(name,bits): 
    return f"CODE::{name.lower()}::"

def sc_type_map(type):    
    return {
        'float':'Float',
        'long': 'Integer',
        'buffer':'Buffer',
        'integer': 'Integer',
        'string': 'Symbol',
        'enum':'Integer', 
        'fft': 'Integer',
        'dataset':'FluidDataSet',
        'labelset':'FluidLabelSet'
    }[type]


def sc_transform_data(object_name,data):
    data['client_name'] = object_name 
    data['category'] = []
    data['keywords'] = []
    data['module'] = ''        
    data['discussion'] = data.pop('discussion','')             

    seealso = [f'Classes/Fluid{x}' for x in tidy_split(data.pop('see-also',''))]
    seealso.extend(tidy_split(data.pop('sc-related','')))
    data['seealso'] = ','.join(seealso)
    data['sc_category'] = data.pop('sc-category','')
    
    data['sc_code'] = data.pop('sc-code','')
    
    params = {x['name']:x for x in data.pop('parameters')}         
    
    data['attributes'] = OrderedDict(
        (filter_fixed_controls(params,fixed=False))    
    )

    fftSettings = data['attributes'].pop('fftSettings',None) 
    if fftSettings: 
        data['attributes'] = {
            **data['attributes'],
            'windowSize': fftSettings['win'], 
            'hopSize': fftSettings['hop'], 
            'fftSize':  fftSettings['fft']
        }
    
    # move 'padding to end'
    padding = data['attributes'].pop('padding',None)    
    if padding:
        data['attributes'] = {**data['attributes'], 'padding': padding}

    data['arguments'] = OrderedDict(
        filter_fixed_controls(params,fixed=True) 
    )
    
    data['messages'] = {x['name']:x for x in data.pop('messages')}
    
    for n,m in data['messages'].items(): 
        m['args'] = {x['name']:x for x in m.pop('args')}
    
    return data

def choose_template(client_data):
    return f"schelp_{client_data['species']}.schelp"

def configure_jinja(environment, client_index, args):    
    environment.filters['example_code'] = lambda name: f'{name}.scd'

settings = {   
    'namer':sc_object_namer,     
    'template': choose_template,
    'extension': 'schelp',
    'types': sc_type_map,
    'glob': '**/*.json', 
    'parameter_link': sc_jinja_parameter_link, 
    # 'write_cross_ref': (sc_visit_flucoma_reference,sc_depart_flucoma_reference),
    'code_block': 'code::{}::', 
    'writer': SCDocWriter, 
    'rst_render': rst_filter,
    'topic_extension': 'schelp', 
    'topic_subdir': 'guides',
    'topic_template':'schelp_topic.schelp',
    'transform': sc_transform_data, 
    'post': None, 
    'defaults': defaults, 
    'jinja_extra': configure_jinja
}
