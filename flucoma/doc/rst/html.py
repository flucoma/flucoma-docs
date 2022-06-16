# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).


from .common import LoggingDocutilsReader

from docutils import nodes
from docutils.utils import Reporter
from docutils.core import publish_parts
from docutils.writers import html4css1, Writer
  

from functools import partial 
from jinja2 import pass_context
from markupsafe import Markup

import logging
import re

class FlucomaCrossRefTranslator(html4css1.HTMLTranslator):
    """docutils translator for Max ref    
    """    
    def visit_reference(self,node):
        if 'flucoma-object' in node:
            self.visit_flucoma_reference(node)
        elif 'flucoma-topic' in node:
            self.visit_flucoma_topic(node)
        elif 'object-link' in node: 
            self.visit_object_link(node)
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
            
            def visit_object_link(self,node):
                f = driver['write_object_ref']
                f(self,node)
                raise nodes.SkipNode; 

            def depart_flucoma_reference(self,node):    
                partial(driver['write_cross_ref'][1], data = index)(self,node)
                
            def visit_literal(self, node)    :
                f = driver.get('code_block',lambda x: x) 
                self.body.append(f(node.astext()))
                raise nodes.SkipNode 
                                
        
        self.translator_class = ConcreteTranslator


# def rst_callback(msg):
#     print('Callback!', msg)


@pass_context #tells jinja to pass in its Context instance, in which we have goodies
def rst_filter(ctx,value):    
    if value is None or len(value) == 0:
         return ''
    logging.debug('Parsing rst block')
         
        
    driver = ctx.parent['driver']
    index =  ctx.parent['index']
    
    raw_role="""
.. role:: raw-html(raw)
   :format: html\n
"""
    # value = raw_role + value
    value += f"\n\n.. |buffer| replace:: {driver.get('buffer-string','buffer')}\n"
        
    # logging.warn(value)

    #stop docutils mirroing warnings to console, but we probably want to see errors
    settings = {'report_level':Reporter.ERROR_LEVEL,'flucoma-host':ctx['host']} 
    
    tre = publish_parts(source=value, 
                                writer = FluidHTMLWriter(index, driver),  
                                reader = LoggingDocutilsReader(),
                                settings_overrides=settings)
    # logging.warn(tre['fragment'])
    return Markup(tre['fragment'])
    
    
class RSTSripper(nodes.GenericNodeVisitor): 
    
    def __init__(self,document):
        super(RSTSripper,self).__init__(document)
        self.settings = settings = document.settings
        self.body = []
    
    def astext(self):
        return ''.join(self.body)
    
    def default_visit(self, node): 
        self.body.append(node.astext())
        raise nodes.SkipNode

class NoRSTWriter(Writer):
    def __init__(self):
        super(NoRSTWriter,self).__init__()
        self.translator_class = RSTSripper
    
    def translate(self):
        self.visitor = visitor = self.translator_class(self.document)
        self.document.walkabout(visitor)
        self.output = visitor.astext()

@pass_context
def no_rst_filter(ctx, value):    
    if value is None or len(value) == 0:
         return ''
    logging.debug('Parsing no-rst block')
                 
    driver = ctx.parent['driver']
    index =  ctx.parent['index']
    
    value = re.sub(r'\|buffer\|','buffer~',value)
    
    #stop docutils mirroing warnings to console, but we probably want to see errors
    settings = {'report_level':Reporter.ERROR_LEVEL,'flucoma-host':ctx['host']} 
    
    tre = publish_parts(source=value, 
                                writer = NoRSTWriter(),  
                                reader = LoggingDocutilsReader(),
                                settings_overrides=settings)
    return Markup(tre['whole'])
        
        
