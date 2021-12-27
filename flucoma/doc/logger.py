import logging
import copy 
from contextlib import contextmanager
from collections.abc import Mapping

logging_context = []

@contextmanager
def add_context(*args):  
    global  logging_context 
    length = len(logging_context)
    try: 
        yield logging_context.extend(args); 
    finally:
        logging_context = logging_context[:length]


# def factory(name, level, fn, lno, msg, args, exc_info, func=None, sinfo=None, **kwargs):
# 

class ContextView(Mapping):
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
        
class ContextFilter(logging.Filter):

    def filter(self, record):        
        record.context = logging_context.copy()
        return True

class ContextLogger(logging.LoggerAdapter):
    
    def __init__(self, logger, extra):
        super(ContextLogger, self).__init__(logger, extra)
        self.env = extra

    def process(self, msg, kwargs):
        passed_context = kwargs['extra'].pop('context',[])
        msg, kwargs = super(ContextLogger, self).process(msg, kwargs)
        result = copy.deepcopy(kwargs)        
        context = result['extra'].pop('context',[])   
        context.append(passed_context)
        result['extra']['context'] = context
        return msg, result


        
