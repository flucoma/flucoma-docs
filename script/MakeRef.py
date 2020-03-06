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
import locale 

"""
So, when running this script from Xcode the locale is set to 'C', which *hilariously* breaks python's ability to read files and process strings in UTF-8 :manic sobbing emoji:

Presumably it doesn't matter a great deal what this is set to here (??)
Or maybe it will break on machines that don't have a en_GB locale? I DON'T KNOW
"""
locale.setlocale(locale.LC_ALL,'en_GB')

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

for c in clients:
    d = process_client_data(c, args.yaml_path)
    process_template(args.template_path, args.output_path, d, host_vars[args.host])

topics = list(Path('/Users/owen/flucoma_paramdump/topics').glob('*.yaml'))
for t in topics: 
    process_topic(t,args.template_path,args.output_path,host_vars[args.host])
# print(topics)
