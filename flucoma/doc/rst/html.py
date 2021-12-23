# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).


from docutils.core import publish_parts
from docutils.writers import html4css1
# from docutils.writers.html4css1 import HTMLTranslator
from functools import partial 
from jinja2 import Markup

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
            # self.body.append('</o>')
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


def rst_filter(s, data, driver,**kwargs):    
    if s is None or len(s) == 0:
         return ''
    
    s += "\n\n.. |buffer| replace:: buffer~\n"     
         
    settings = {'report_level':1}
    if(kwargs):
        settings = kwargs['settings']         
    return Markup(publish_parts(source=s,   
                                writer=FluidHTMLWriter(data, driver),
                                settings_overrides=settings)['html_body'])
