import argparse
from jinja2 import Environment, FileSystemLoader
from pathlib import Path
from FluidRefData import *

parser = argparse.ArgumentParser(description='Generate FluCoMa documentation for a given host, using input JSON and YAML data and a jinja template')

parser.add_argument('json_path', type=Path,help='Path to generated JSON client data')

parser.add_argument('yaml_path', type=Path,help='Path to human made YAML client documentation')

parser.add_argument('output_path', type=Path,help='Path to write output files to')

parser.add_argument('template_path', type=Path,help='Path containing Jinja template(s)')

args = parser.parse_args()

env = Environment(
    loader=FileSystemLoader([args.template_path]),
    autoescape=select_autoescape(['html', 'xml'])
)
env.filters['maxtype'] = max_type
env.filters['maxname'] = max_name
env.filters['rst'] = rst_filter

clients = list(args.json_path.glob('**/*.json'))    
args.output_path.mkdir(exist_ok=True)

for c in clients:
    d = process_client_data(c,args.yaml_path)
    process_template(env,'maxref.xml','maxref.xml',args.output_path,d,max_name)
