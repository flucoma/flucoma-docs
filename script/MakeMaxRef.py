from docutils.core import publish_parts
from jinja2 import Template
from jinja2 import Environment, PackageLoader, select_autoescape, Markup
from pathlib import Path
import json
import yaml
from pathlib import Path
from collections import OrderedDict
import os

# All hail SO: https://stackoverflow.com/questions/11309885/jinja2-restructured-markup
def rst_filter(s):
    if not s: return ''
    if len(s) == 0:
         return ''
    return Markup(publish_parts(source=s, writer_name='html')['body'])

def max_type(value):
    type_map = {
        'float':'float64',
        'long': 'int',
        'buffer':'symbol',
        'enum':'int',
        'symbol':'symbol',
        'fft': 'int', 
        'dataset': 'symbol',
        'labelset': 'symbol'
    }
    # print(value)
    return type_map[value] if value in type_map else 'UNKOWN({})'.format(value)
    # return "atype"

def truefalse(value):
    if value is True: return "1"
    if value is False: return "0" 





def process_client(env, jsonfile):
    print(jsonfile.stem.lower())
    template = env.get_template('maxref.xml')
    data = json.load(open(jsonfile.resolve()))
    human_data = {}
    human_data_path = Path('../doc/'+jsonfile.stem+'.yaml')
    if(human_data_path.exists()):
        human_data = yaml.load(open(human_data_path.resolve(),encoding='utf8'))
        # print(human_data['digest'])

    args={}
    attrs={}

    # data = dict(data) #data is in json array to preserve order,
    
    if not data: return 
    # print(data)
    params = dict(data['params'])
    
    # print(params)
    params['warnings'] = {
        "displayName" : "Warnings",
        "constraints": {
            "min": 0,
            "max": 1
        } ,
        "default": 0,
        "type": "long",
        "size": 1,
        "fixed": False,
        "description" : "Enable warnings to be issued whenever a parameter value is contrained (e.g. clipped)"
    }

    if jsonfile.stem.lower().startswith('buf'):
        params['blocking'] = {
            "displayName" : "Blocking Mode",
            "default": 1,
            "fixed": False,
            "size": 1,
            "type": "enum",
            "values": [
                "Non-Blocking",
                "Blocking (Low Priority)",
                "Blocking (High Priority)"
            ],
            "enum": {
                "Non-Blocking": "Processing runs in a worker thread",
                "Blocking (Low Priority)" : "Processing runs in the main application thread",
                "Blocking (High Priority)" : "(Max only) Processing runs in the scheduler thread"
            },
            "description" : "Set the threading mode for the object"
        }
        params['queue'] = {
            "displayName" : "Non-Blocking Queue Flag",
            "default": 0,
            "fixed": False,
            "size": 1,
            "type": "long",
            "description" : "In non-blocking mode enable jobs to be queued up if successive bangs are sent whilst the object is busy. With the queue disabled, successive bangs will produce a warning. When enabled, the object will processing successively, against the state of its parameters when each bang was sent"
        }

    for d,v in params.items():
        # print(d)
        fixed = False;
        # description = ''

        param = {}

        param.update({d.lower():v})
        
        # if(d): print(d)
        # if(human_data and human_data['parameters']): print("I haz yaml")

        if human_data and human_data['parameters'] and d in human_data['parameters']:
            if 'description' in human_data['parameters'][d]:
                param[d.lower()].update({'description': human_data['parameters'][d]['description']})
            if 'enum' in human_data['parameters'][d] and 'values' in v:
                param[d.lower()]['enum'] = dict(zip(v['values'],human_data['parameters'][d]['enum'].values()))


        if human_data and human_data['parameters'] and d == 'fftSettings':
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
    
    messages = dict(data['messages'])

    for d,v in messages.items():
        if human_data and human_data['messages'] and d in human_data['messages']:
            if 'description' in human_data['messages'][d]:
                messages[d].update({'description': human_data['messages'][d]['description']})

    # print(args)
    digest  = human_data['digest'] if 'digest' in human_data else 'A Fluid Decomposition Object'
    description = human_data['description'] if 'description' in human_data else ''
    discussion = human_data['discussion'] if 'discussion' in human_data else ''
    client  = 'fluid.{}~'.format(jsonfile.stem.lower())
    attrs = OrderedDict(sorted(attrs.items(), key=lambda t: t[0]))
    with open('../maxref/{}.maxref.xml'.format(client),'w',encoding='utf8') as f:
        f.write(template.render(
            arguments=args,
            attributes=attrs,
            messages=messages,
            client_name=client,
            digest=digest,
            description=description,
            discussion=discussion
            ))

    #Also return a dictionary summarizing the object for obj-qlookup.json
    objLookupEntry = {
        'digest': digest,
        'module':'fluid decomposition',
        'keywords':[],
        'category': [],
        'seealso': []
    }

    return objLookupEntry;


def main():
    env = Environment(
        loader=PackageLoader('MakeMaxRef', 'templates'),
        autoescape=select_autoescape(['html', 'xml'])
    )
    env.filters['maxtype'] = max_type
    env.filters['rst'] = rst_filter
    env.filters['truefalse'] = truefalse
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
