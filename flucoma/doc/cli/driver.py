# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from flucoma.doc.rst.html import FluidHTMLWriter, rst_filter

from .. legacy.adaptor import make_it_like_it_was
from docutils import nodes, utils
import json

def buffer_reference_role(role, rawtext, text, lineno, inliner,
                           options={}, content=[]):
    return 'file'

def cli_visit_flucoma_reference(self, node, data, transform_name):
    if transform_name:
        if(node.astext()) in data:
            name = cli_object_namer(data[node.astext()]) 
        else: 
            name = f'Unresolved lookup ({node.astext()})'
    else: 
        name = node.astext()
    attrs = {'href': name + '.html'}
    node[:] = [nodes.raw('',name, format='html')]
    self.body.append(self.starttag(node, 'a','',**attrs))
    
def cli_depart_flucoma_reference(self, node, data):
    self.body.append('</a>')

def cli_object_namer(data):    
    tilde = '~' if not data['client_name'].startswith('Buf') else ''
    return f"fluid.{data['client_name'].lower()}{tilde}"    

def cli_jinja_parameter_link(name,bits): 
    return f"<code>{name.lower()}</code>"

def cli_type_map(type):    
    return {
        'float':'number',
        'long': 'number',
        'buffer':'symbol',
        'integer': 'int',
        'string': 'symbol',
        'enum':'int', 
        'fft': 'int',
        'dataset':'symbol',
        'labelset':'symbol'
    }[type]
    
def transform_data(client, data):
    return make_it_like_it_was(client, data)

settings = {   
    'namer':cli_object_namer,     
    'template': 'cli_htmlref.html',    
    'extension': 'html',
    'types': cli_type_map,
    'glob': '**/*.json', 
    'parameter_link': cli_jinja_parameter_link, 
    'write_cross_ref': (cli_visit_flucoma_reference,cli_depart_flucoma_reference),
    'code_block': '<m>{}</m>', 
    'writer': FluidHTMLWriter, 
    'rst_render': rst_filter,
    'topic_extension':'.html',
    'topic_subdir': '',
    'topic_template':'cli_htmltopic.html',
    'transform': transform_data, 
    'post': None, 
    'defaults': None
}
