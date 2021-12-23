# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from collections import OrderedDict

from ..transformers import * 

def make_it_like_it_was(object_name, data):
    
    data['client_name'] = object_name 
    data['category'] = []
    data['keywords'] = []
    data['module'] = 'fluid decomposition'
    
    data['discussion'] = data.pop('discussion','') 
        
    # data['seealso'] = [
    #     x.strip() for x in filter(
    #         lambda x: len(x),
    #         data.pop('see-also','').split(',')
    #     )
    # ]
    # 
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
    
    # data['attributes'] = OrderedDict(
    #     sorted(filter(lambda x: not x[1]['fixed'],params.items()))
    # )

    data['attributes'] = OrderedDict(
        sorted(filter_fixed_controls(params,fixed=False))    
    )

    # data['arguments'] = OrderedDict(
    #     filter(lambda x:  x[1]['fixed'],params.items())
    # )
    
    data['arguments'] = OrderedDict(
        filter_fixed_controls(params,fixed=True) 
    )
    
    data['messages'] = {x['name']:x for x in data.pop('messages')}
    
    for n,m in data['messages'].items(): 
        m['args'] = {x['name']:x for x in m.pop('args')}
    
    return data 
