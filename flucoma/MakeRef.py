# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import argparse
from pathlib import Path
from FluidRefData import *
import json
import locale 


def write_max_indices(idx,path):
    maxdb_objs = {'maxdb':{'externals':{}}}
    qlookup = {}
    for client,data in idx.items():
        maxname = 'fluid.{}~'.format(data['client'].lower())
        if 'messages' in data: 
            if 'dump' in data['messages']:
                maxdb_objs['maxdb']['externals'][maxname]={
                    'object':'fluid.libmanipulation',
                    'package':'Fluid Corpus Manipulation'
                }
        qlookup[maxname] = {
            'digest': data['digest'],'category':['Fluid Corpus Manuipulation']
        }
    
    maxdbfile = path / 'max.db.json'
    with open(maxdbfile,'w') as f:
        json.dump(maxdb_objs,f,sort_keys=True, indent=4)
    qlookup_file = path / 'flucoma-obj-qlookup.json'
    with open(qlookup_file,'w') as f: 
        json.dump(qlookup,f,sort_keys=True, indent=4)
    
    
"""
Set default locale, in case it hasn't been, otherwise we can't read text
"""
locale.setlocale(locale.LC_ALL,'')

parser = argparse.ArgumentParser(
    description='Generate FluCoMa documentation for a given host, using input JSON and YAML data and a jinja template')

parser.add_argument('host', choices=['max','pd','cli'])

parser.add_argument('json_path', type=Path,
                    help='Path to generated JSON client data')

parser.add_argument('yaml_path', type=Path,
                    help='Path to human made YAML client documentation')

parser.add_argument('output_path', type=Path,
                    help='Path to write output files to')

parser.add_argument('template_path', type=Path,
                    help='Path containing Jinja template(s)')

args = parser.parse_args()

clients = list(args.json_path.glob(host_vars[args.host]['glob']))
args.output_path.mkdir(exist_ok=True)

print('OUTPUT PATH {}'.format(args.output_path))

index = {}

for c in clients:
    d = process_client_data(c, args.yaml_path)
    index[c] = process_template(args.template_path, args.output_path, d, host_vars[args.host])

index_path = args.output_path / '../interfaces'
index_path.mkdir(exist_ok=True)

write_max_indices(index,index_path)

topics = list(Path('/Users/owen/flucoma_paramdump/topics').glob('*.yaml'))
for t in topics: 
    process_topic(t,args.template_path,args.output_path,host_vars[args.host])
# print(topics)
