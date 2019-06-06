from jinja2 import Template
from jinja2 import Environment, PackageLoader, select_autoescape
from pathlib import Path
import json
import yaml
from pathlib import Path
import os
# template = Template('Hello {{ name }}!')
# template.render(name='John Doe')

def max_type(value):
    type_map = {
        'float':'float64',
        'long': 'int',
        'buffer':'symbol',
        'enum':'int'
    }
    # print(value)
    return type_map[value] if value in type_map else 'UNKOWN'
    # return "atype"

def process_client(env, jsonfile):
    # print(jsonfile.stem.lower())
    template = env.get_template('maxref.xml')
    data = json.load(open(jsonfile.resolve()))
    human_data = {}
    human_data_path = Path('../doc/'+jsonfile.stem+'.yaml')
    if(human_data_path.exists()):
        human_data = yaml.load(open(human_data_path.resolve()))
        # print(human_data['digest'])

    args={}
    attrs={}

    for d,v in data.items():
        # print(d)
        fixed = False;
        description = ''

        param = {}

        param.update({d.lower():v})

        if 'parameters' in human_data and d in human_data['parameters']:
            if 'description' in human_data['parameters'][d]:
                param[d.lower()].update({'description': human_data['parameters'][d]['description']})

        if 'fixed' in v:
            fixed = v['fixed']
        if fixed:
            args.update(param)
        else:
            attrs.update(param)

    # print(attrs)
    digest  = human_data['digest'] if 'digest' in human_data else 'A Fluid Decomposition Object'
    description = human_data['description'] if 'description' in human_data else ''
    client  = 'fluid.{}~'.format(jsonfile.stem.lower())

    with open('../maxref/{}.maxref.xml'.format(client),'w') as f:
        f.write(template.render(
            arguments=args,
            attributes=attrs,
            client_name=client,
            digest=digest,
            description=description
            ))


def main():
    env = Environment(
        loader=PackageLoader('MakeMaxRef', 'templates'),
        autoescape=select_autoescape(['html', 'xml'])
    )
    env.filters['maxtype'] = max_type
    p = Path('../json')
    clients = list(p.glob('**/*.json'))
    out = Path('../maxref')
    out.mkdir(exist_ok=True)
    for c in clients:
        process_client(env, c)
    # process_client(env, Path('../json/BufCompose.json'))

if __name__== "__main__":
  main()

# print(clients)

# print(template.render(client_name='AClient'))
