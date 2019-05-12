from jinja2 import Template
from jinja2 import Environment, PackageLoader, select_autoescape
import json
from pathlib import Path
import os
# template = Template('Hello {{ name }}!')
# template.render(name='John Doe')


def process_client(env, jsonfile):
    print(jsonfile.stem.lower())
    template = env.get_template('maxref.xml')
    data = json.load(open(jsonfile.resolve()))

    args={}
    attrs={}

    for d,v in data.items():
        # print(d)
        fixed = False;
        if 'fixed' in v:
            fixed = v['fixed']
        if fixed:
            args.update({d.lower():v})
        else:
            attrs.update({d.lower():v})
    client  = 'fluid.{}~'.format(jsonfile.stem.lower())
    with open('../maxref/{}.maxref.xml'.format(client),'w') as f:
        f.write(template.render(arguments=args,attributes=attrs,client_name=client))


def main():
    env = Environment(
        loader=PackageLoader('MakeMaxRef', 'templates'),
        autoescape=select_autoescape(['html', 'xml'])
    )
    p = Path('../json')
    clients = list(p.glob('**/*.json'))
    out = Path('../maxref')
    out.mkdir(exist_ok=True)
    for c in clients:
        process_client(env, c)

if __name__== "__main__":
  main()

# print(clients)

# print(template.render(client_name='AClient'))
