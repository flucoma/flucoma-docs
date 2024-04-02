# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import logging
from contextlib import contextmanager
from collections.abc import Mapping

logging_context = []


class ContextFilter(logging.Filter):
    '''
    Filter for the python logging framework that adds the logging context to the current LogRecord (the Format still needs to be set in the logging config to see the context in the string though)
    '''
    def filter(self, record):        
        record.context = ' '.join(logging_context)
        return True

@contextmanager
def add_context(*args):  
    '''
    contextmanager decorator function to be used in `with` blocks to add to the current logging context, so that we can trace a hierarchy through log mesages (e.g. object::control or object::message), e.g 
    
    ```
    with add_context(`BufCompose`):
        #stuff
        with add_context (`process`):
            #stuff 
            logging.warning('ohno')
    ```
    would preface the log message with the context 'BufCompose, process'
    '''
    global  logging_context 
    length = len(logging_context)
    
    try: 
        yield logging_context.extend(*args); 
    finally:
        logging_context = logging_context[:length]


class ContextView(Mapping):
    '''
    Make a view round a dict (or any sort of Mapping) that uses add_context in the __iter__ generator to add the current key to the logging context. Used to wrap the collections of contols and messages for processing in Jinja, so that any logging messages are contextualised w/r/t the object at hand
    '''
    def __init__(self,mapping,*args):
        self.mapping = mapping 
        self.args = args
    
    def __iter__(self):
        for k,v in self.mapping.items(): 
            with add_context(*self.args,k):                
                yield k

    def __len__(self): 
        return len(self.mapping)
    
    def __getitem__(self,key):
        return self.mapping[key]
        
