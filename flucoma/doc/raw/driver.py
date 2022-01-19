# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import json
from .. transformers import default_transform

def transform_data(client, data):
    return default_transform(client, data)

def write_index(idx,program_args):
    
    path = program_args.output_path 
    path.mkdir(exist_ok=True)
    apifile = path / 'flucoma.api.json'
    with open(apifile,'w') as f:
        json.dump(idx,f,sort_keys=True, indent=4)
    
    maxdb_objs = {'maxdb':{'externals':{}}}

settings = {   
    'glob': '**/*.json', 
    'writer': FluidHTMLWriter, 
    'transform': transform_data, 
    'post': write_index, 
    'defaults': None, 
}
