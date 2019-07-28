from docutils.core import publish_parts
from jinja2 import Template
from jinja2 import Environment, PackageLoader, select_autoescape, Markup
from pathlib import Path
import json
import yaml
from pathlib import Path
import os
# template = Template('Hello {{ name }}!')
# template.render(name='John Doe')

# All hail SO: https://stackoverflow.com/questions/11309885/jinja2-restructured-markup
def rst_filter(s):
    if len(s) == 0:
         return ''
    return Markup(publish_parts(source=s, writer_name='html')['body'])

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
    print(jsonfile.stem.lower())
    template = env.get_template('maxref.xml')
    data = json.load(open(jsonfile.resolve()))
    human_data = {}
    human_data_path = Path('../doc/'+jsonfile.stem+'.yaml')
    if(human_data_path.exists()):
        human_data = yaml.load(open(human_data_path.resolve()))
        # print(human_data['digest'])

    args={}
    attrs={}

    data = dict(data) #data is in json array to preserve order,

    for d,v in data.items():
        # print(d)
        fixed = False;
        # description = ''

        param = {}

        param.update({d.lower():v})

        if 'parameters' in human_data and d in human_data['parameters']:
            if 'description' in human_data['parameters'][d]:
                param[d.lower()].update({'description': human_data['parameters'][d]['description']})
            if 'enum' in human_data['parameters'][d] and 'values' in v:
                param[d.lower()]['enum'] = dict(zip(v['values'],human_data['parameters'][d]['enum'].values()))

        if d == 'fftSettings':
            fftdesc ='FFT settings consist of three numbers representing the window size, hop size and FFT size:\n'
            if 'windowSize' in  human_data['parameters']:
                fftdesc += '   \n* ' + human_data['parameters']['windowSize']['description'];
            if 'hopSize' in human_data['parameters']:
                fftdesc += '   \n* ' + human_data['parameters']['hopSize']['description'];
            if 'fftSize' in human_data['parameters']:
                fftdesc += '   \n* ' + human_data['parameters']['fftSize']['description'];
            fftdesc += '\n'
            param[d.lower()].update({'description': fftdesc})


        if 'fixed' in v:
            fixed = v['fixed']
        if fixed:
            args.update(param)
        else:
            attrs.update(param)

    # print(args)
    digest  = human_data['digest'] if 'digest' in human_data else 'A Fluid Decomposition Object'
    description = human_data['description'] if 'description' in human_data else ''
    discussion = human_data['discussion'] if 'discussion' in human_data else ''
    client  = 'fluid.{}~'.format(jsonfile.stem.lower())

    with open('../maxref/{}.maxref.xml'.format(client),'w') as f:
        f.write(template.render(
            arguments=args,
            attributes=attrs,
            client_name=client,
            digest=digest,
            description=description,
            discussion=discussion
            ))


def main():
    env = Environment(
        loader=PackageLoader('MakeMaxRef', 'templates'),
        autoescape=select_autoescape(['html', 'xml'])
    )
    env.filters['maxtype'] = max_type
    env.filters['rst'] = rst_filter
    p = Path('../json')
    clients = list(p.glob('**/*.json'))
    out = Path('../maxref')
    out.mkdir(exist_ok=True)
    for c in clients:
        process_client(env, c)
    # process_client(env, Path('../json/NMFFilter.json'))

if __name__== "__main__":
  main()

# print(clients)

# print(template.render(client_name='AClient'))
