# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from docutils import nodes, utils

from .. legacy.adaptor import make_it_like_it_was
import json

def buffer_reference_role(role, rawtext, text, lineno, inliner,
                           options={}, content=[]):
    return 'array'

# class PDHTMLTranslator(html4css1.HTMLTranslator):
#     """docutils translator for PD ref    
#     """    
#     def visit_reference(self,node):    
#         atts = {'class' : 'fluid_object'}    
#         if('flucoma' in node):
#             pdname = pd_object_namer(node.astext())  
#             node[:] = [nodes.raw('',pdname,format='html')]
#             atts['href'] = pdname + '.html'
#             self.body.append(self.starttag(node, 'a', '',**atts))
#             # print(inspect.getmembers(node))
#         else:
#             super().visit_reference(node)


def pd_visit_flucoma_reference(self, node, data, transform_name):
    if transform_name:
        if(node.astext()) in data:
            name = pd_object_namer(data[node.astext()]) 
        else: 
            name = f'Unresolved lookup ({node.astext()})'
    else: 
        name = node.astext()
    attrs = {'href': name + '.html'}
    node[:] = [nodes.raw('',name, format='html')]
    self.body.append(self.starttag(node, 'a','',**attrs))
    
def pd_depart_flucoma_reference(self, node, data):
    self.body.append('</a>')


def pd_object_namer(data):    
    tilde = '~' if not data['client_name'].startswith('Buf') else ''
    return f"fluid.{data['client_name'].lower()}{tilde}"    


def pd_jinja_parameter_link(name,bits): 
    return f"<code>{name.lower()}</code>"

def pd_type_map(type):    
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
    'namer':pd_object_namer,     
    'template': 'pd_htmlref.html',
    'extension': 'html',
    'types': pd_type_map,
    'glob': '**/*.json', 
    'parameter_link': pd_jinja_parameter_link, 
    'write_cross_ref': (pd_visit_flucoma_reference,pd_depart_flucoma_reference),
    'code_block': '<m>{}</m>', 
    # 'translator': PDHTMLTranslator, 
    'topic_extension': '.html', 
    'topic_subdir': '',
    'topic_template':'pd_htmltopic.html',
    'transform': transform_data, 
    'post': None
}
