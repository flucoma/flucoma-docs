# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).



import re

from flucoma.doc.rst.html import FluidHTMLWriter, rst_filter
from .. transformers import default_transform
from docutils import nodes

'''
CLI driver file
'''

def buffer_reference_role(role, rawtext, text, lineno, inliner,
                           options={}, content=[]):
    '''
    Not yet used

    docutils Role for substituting the correct string in place of 'buffer' in reST docs
    '''
    return 'file'

def cli_visit_flucoma_reference(self, node, data, transform_name):
    '''
    docutils Translator visit function for rendering links to FluCoMa objects in the CLI docs
    '''
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
    '''
    closes the link opened by `cli_visit_flucoma_reference`

    perhaps this is surplus to requirements because we know (?) that the link content isn't going to have any extra markup, so we could just close in `visit` by raising `SkipNode`
    '''
    self.body.append('</a>')

def cli_object_namer(data):
    '''
    returns a properly formatted name for the CLI object, given the stub, e.g. `BufHPSS` beccomes `fluid-hpss`

    nb the CLI only uses Buf* objects
    '''
    return f"fluid-{data['client_name'].lower().split('buf')[1]}"

def cli_jinja_parameter_link(name,bits):
    '''
    not yet used?

    renders a reST link to a parameter as html `<code>`.

    todo: This could be turned into an actual link if we rendered anchors around parameter and message definitions
    '''
    return f"<code>{name.lower()}</code>"

def cli_type_map(type):
    '''
    map types from generated JSON to 'types' for rendered HTML

    will throw KeyError if an unown type is passed in
    '''
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
    '''
    post-merge processing for data. defers to function in flucoma.doc.legacy that reproduces pre-refactor behaviour
    '''
    return default_transform(client, data)

'''

'''
settings = {
    'namer':cli_object_namer,
    'template': 'cli_htmlref.html',
    'extension': 'html',
    'types': cli_type_map,
    'glob': '**/Buf*.json',
    'glob_filter': lambda x: re.match('Buf(?!Compose).*',x.stem) is not None,
    'parameter_link': cli_jinja_parameter_link,
    'write_cross_ref': (cli_visit_flucoma_reference,cli_depart_flucoma_reference),
    'code_block': '<code>{}</code>',
    'writer': FluidHTMLWriter,
    'rst_render': rst_filter,
    'topic_extension':'html',
    'topic_subdir': '',
    'client_subdir': '',
    'topic_template':'cli_htmltopic.html',
    'transform': transform_data,
    'post': None,
    'defaults': None,
    'buffer-string':'file'
}
