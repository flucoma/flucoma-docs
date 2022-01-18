# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from collections import OrderedDict

"""
takes a an nested dict of controls, each assumed to have a 'fixed' key, returns an iterator to fixed = True by default. If elements don't have a 'fixed' key then you'll get a KeyError

returns an iterator 
"""
def filter_fixed_controls(controls,fixed=True):
    return filter(lambda x:  x[1]['fixed'] == fixed, controls.items())

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
    
    params = {x['name']:x for x in data.pop('parameters')} 
    
    data['attributes'] = OrderedDict(
        sorted(filter_fixed_controls(params,fixed=False))    
    )

    data['arguments'] = OrderedDict(
        filter_fixed_controls(params,fixed=True) 
    )
    
    data['messages'] = {x['name']:x for x in data.pop('messages')}
    
    for n,m in data['messages'].items(): 
        m['args'] = {x['name']:x for x in m.pop('args')}
    
    return data 
