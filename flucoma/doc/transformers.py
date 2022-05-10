# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import logging
from flucoma.doc import logger
from collections import OrderedDict
import copy
from functools import reduce

"""
takes a an nested dict of controls, each assumed to have a 'fixed' key, returns an iterator to fixed = True by default. If elements don't have a 'fixed' key then you'll get a KeyError

returns an iterator 
"""
def filter_fixed_controls(controls,fixed=True):    
    
    # def fil(item):
    #     return item[1].get('fixed',False) == fixed
    
    return { k: v for k,v in controls.items() if v.get('fixed',False)  == fixed}
    # return [ (k,v) for k,v in controls.items() if v.get('fixed',False)  == True]
    # return filter(lambda x:  x[1]['fixed'] == fixed, controls.items())

def filter_primary_controls(controls):
    # primaries = filter(lambda x: x[1].get('primary',False) == True, controls.items())
    primaries = copy.deepcopy({ k: v for k,v in controls.items() if v.get('primary',False) ==  True})    
    for n,v in primaries.items(): 
        v['description'] = f"Shorthand argument for ``{n}``"
    return primaries

"""
given a [comma] separated string,break it up discarding empty items and trimming whitespace 

returns an iterator 
"""
def tidy_split(string,separator=','): 
    return map(lambda x: x.strip(),
        filter(lambda x: len(x), string.split(separator))
    )
 
def default_transform(object_name, data):
    
    data['client_name'] = object_name 
    data['category'] = []
    data['keywords'] = []
    data['module'] = 'fluid decomposition'
    
    data['discussion'] = data.pop('discussion','') 

    data['seealso'] = [x for x in tidy_split(data.pop('see-also',''))]

    with logger.add_context([object_name]): 
        for k in ['max-seealso', 'pd-seealso']:    
            if k in data: 
                data[k.replace('-', '_')] = [x.strip() for x in data.get(k, '').split(',')]
            else:
                logging.warning(f"No {k} entry")
                
    data['parameters'].append({
        'name':'warnings',
        'constraints': {'max': 1, 'min': 0},
        'default': 0,
        'description': 'Enable warnings to be issued '
                     'whenever a parameter value is '
                     'constrained (e.g. clipped)',
        'displayName': 'Warnings',
        'fixed': False,
        'size': 1,
        'type': 'long'
    })
    
    #any parameter is an FFT (conventionally just the one,mind)?
    hasfft = reduce(lambda acc, x: acc or (x['type'] == 'fft'), data['parameters'],False)
    
    if hasfft: 
        data['parameters'].append({
            'name':'maxfftsize', 
            'constraints': {}, 
            'default': -1, 
            'description': 'Set an explicit upper bound on the FFT size at object instantiation. The default of -1 sets this to whatever the initial FFT size is',
            'displayName': 'Maximum FFT Size', 
            'fixed': False, 
            'size': 1, 
            'type': 'long'
        })
    
    runtime_max_params = filter(lambda x: x.get('runtimemax',False) ==True, data['parameters'])
    
    for r in runtime_max_params:
        r['size'] = 1
        data['parameters'].append({
            'name': f"max{r['name']}",
            'constraints':{},
            'default': -1,
            'description': f"Manually sets a maximum value for ``{r['name']}``. Can only be set at object instantiation. The default of -1 sets this equal to the initial value of ``{r['name']}``",
            'displayName': f"Maximum {r['displayName']}",
            'fixed':False, 
            'size':1,
            'type': r['type']
        })
    
    if(data['input_type'] == 'control'):
        data['parameters'].insert(0,{
            'name':'inputsize',
            'constraints': {'min': 0},
            'default': 32,
            'description': 'number of items in the input list',
            'displayName': 'Input List Size',
            'fixed': True,
            'size': 1,
            'type': 'long'        
        })
        data['parameters'].append({
            'name':'autosize',
            'constraints': {'max': 1, 'min': 0},
            'default': 1,
            'description': 'If the input list is a different size to ``inputsize`` then automatically resize the internal data. If the object is triggered from the high priority thread and a resize is needed, then the call will be deferred to the low priority thread and a warning will be posted to the console.',
            'displayName': 'Automatically resize input',
            'fixed': False,
            'size': 1,
            'type': 'long'
        })        

    params = {x['name']:x for x in data.pop('parameters')} 
    
    data['attributes'] = OrderedDict(
        sorted(filter_fixed_controls(params,fixed=False).items())    
    )

    data['arguments'] = {
        **filter_primary_controls(params),
        **filter_fixed_controls(params,fixed=True)
    }
        
    data['messages'] = {x['name']:x for x in data.pop('messages')}
    
    for n,m in data['messages'].items(): 
        m['args'] = {x['name']:x for x in m.pop('args')}
    
    return data 
