# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).


from .common import LoggingDocutilsReader

from docutils.utils import Reporter
from docutils.core import publish_parts
from docutils.writers import html4css1

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


@pass_context #tells jinja to pass in its Context instance, in which we have goodies
def rst_filter(ctx,value):    
    if value is None or len(value) == 0:
         return ''
    logging.debug('Parsing rst block')
         
        
    driver = ctx.parent['driver']
    index =  ctx.parent['index']
    
    value += f"\n\n.. |buffer| replace:: {driver.get('buffer-string','buffer')}\n"
        
    
    #stop docutils mirroing warnings to console, but we probably want to see errors
    settings = {'report_level':Reporter.ERROR_LEVEL,'flucoma-host':ctx['host']} 
    
    tre = publish_parts(source=value, 
                                writer = FluidHTMLWriter(index, driver),  
                                reader = LoggingDocutilsReader(),
                                settings_overrides=settings)
    
    return Markup(tre['fragment'])
