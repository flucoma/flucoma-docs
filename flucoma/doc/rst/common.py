# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import logging
from docutils import nodes
from docutils.transforms import Transform
from docutils.transforms.references import Substitutions
from docutils.readers.standalone import Reader

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
        return Reader.get_transforms(self) + [Substitutions] + [LogDocutilsMessages] 
