# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).


from docutils import nodes
from docutils.utils import Reporter
from docutils.core import publish_parts
from docutils.writers import html4css1
from docutils.readers.standalone import Reader
from docutils.transforms import TransformError, Transform

from functools import partial 
from jinja2 import pass_context
from markupsafe import Markup

import logging

class FlucomaCrossRefTranslator(html4css1.HTMLTranslator):
    """docutils translator for Max ref    
    """    
    def visit_reference(self,node):
        if 'flucoma-object' in node:
            self.visit_flucoma_reference(node)
        elif 'flucoma-topic' in node:
            self.visit_flucoma_topic(node)
        else:
            super().visit_reference(node)
    
    def depart_reference(self,node):
        if 'flucoma-object' in node or 'flucoma-topic' in node:
            self.depart_flucoma_reference(node)
        else: 
            super().depart_reference(node)

class FluidHTMLWriter(html4css1.Writer):
    """docutils writer for Max ref
    """    
    def __init__(self, index, driver):
        html4css1.Writer.__init__(self)
        
        class ConcreteTranslator(FlucomaCrossRefTranslator): 
            def visit_flucoma_reference(self,node):
                 f = partial(driver['write_cross_ref'][0], 
                             data = index, transform_name = True)
                 f(self,node)

            def visit_flucoma_topic(self,node):
                 f = partial(driver['write_cross_ref'][0], 
                             data = index, transform_name = False)
                 f(self,node)
                 
            def depart_flucoma_reference(self,node):    
                partial(driver['write_cross_ref'][1], data = index)(self,node)
        
        self.translator_class = ConcreteTranslator


# def rst_callback(msg):
#     print('Callback!', msg)


class LogDocutilsMessages(Transform):
    """
    Log system messages from docutils by applying a post-Transform after reading an rst block 
    """
    default_priority = 870

    def apply(self):
        # find all <problematic> nodes, so we can try and actually log the markup that caused the problem 
        for node in tuple(self.document.findall(nodes.problematic)):   
            #locate the <system_message> node that corresponds to the problem
            for m in self.document.parse_messages:
                if node.get('refid') in m.get('ids'): 
                    #strip all the docutils gumph, just get the message
                    system_message = m.children[0].astext() + '\n'
                    #try and grab some surroundng context 
                    try: 
                        context_before = node.previous_sibling().pformat()
                    except (AttributeError, IndexError): 
                        context_before = ''
                    
                    try: 
                        context_after = node.parent[
                                                node.parent.index(node) + 1
                                            ].pformat()
                    except IndexError: 
                        context_after = ''
    
                    logging.warning('reStructuredText sadness: ' 
                                    + system_message 
                                    + context_before 
                                    + node.pformat() 
                                    + context_after) 
                    
        

class LoggingDocutilsReader(Reader):        
        '''
        Exists only to attach our logging transform to the reading process 
        '''
        def get_transforms(self):            
            return Reader.get_transforms(self) + [LogDocutilsMessages]
    

@pass_context #tells jinja to pass in its Context instance, in which we have goodies
def rst_filter(ctx,value):    
    if value is None or len(value) == 0:
         return ''
    logging.debug('Parsing rst block')
    value += "\n\n.. |buffer| replace:: buffer~\n"     
        
    driver = ctx.parent['driver']
    index =  ctx.parent['index']
    #stop docutils mirroing warnings to console, but we probably want to see errors
    settings = {'report_level':Reporter.ERROR_LEVEL} 
    return Markup(publish_parts(source=value, 
                                writer = FluidHTMLWriter(index, driver),  
                                reader = LoggingDocutilsReader(),
                                settings_overrides=settings)['html_body'])
