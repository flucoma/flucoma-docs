from docutils.core import publish_parts
from jinja2 import Template
from jinja2 import Environment, PackageLoader, FileSystemLoader, select_autoescape, Markup
from pathlib import Path
import json
import yaml
from pathlib import Path
from collections import OrderedDict
import os
import sys 

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
    return type_map[value] if value in type_map else 'UNKNOWN'

def max_name(value): 
    return 'fluid.{}~'.format(value.lower())
    
def pd_name(value):
    name = 'fluid.{}'.format(value.lower())
    tilde = '' if value.lower().startswith('buf') else '~'
    return name + tilde

def pd_type(value):
    type_map = {
        'float':'number',
        'long': 'number',
        'buffer':'symbol',
        'enum':'number'
    }
    return type_map[value] if value in type_map else 'UNKNOWN'

def sc_name(value):
    return 'Fluid{}'.format(value)


def cli_type(value):
    type_map = {
        'float':'number',
        'long': 'number',
        'buffer':'filename',
        'enum':'number'
    }
    return type_map[value] if value in type_map else 'UNKNOWN'
        
def cli_name(value): 
    return 'fluid-'.format(value.lower())    


def process_client_data(jsonfile, yamldir):
    print('Processing reference data for {}'.format(jsonfile.stem))
    # template = env.get_template('maxref.xml')
    data = json.load(open(jsonfile.resolve()))
    human_data = {}
    human_data_path = yamldir / (jsonfile.stem+'.yaml')    
    if(human_data_path.exists()):
        human_data = yaml.load(open(human_data_path.resolve()))
        # print(human_data['digest'])

    args={}
    attrs={}

    data = dict(data) #data is in json array to preserve order,

    data['warnings'] = {
        "displayName" : "Warnings",
        "constraints": {
            "min": 0,
            "max": 1
        } ,
        "default": 0,
        "type": "long",
        "size": 1,
        "fixed": False,
        "description" : "Enable warnings to be issued whenever a parameter value is constrained (e.g. clipped)"
    }

    if jsonfile.stem.lower().startswith('buf'):
        data['blocking'] = {
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
        data['queue'] = {
            "displayName" : "Non-Blocking Queue Flag",
            "default": 0,
            "fixed": False,
            "size": 1,
            "type": "long",
            "description" : "In non-blocking mode enable jobs to be queued up if successive bangs are sent whilst the object is busy. With the queue disabled, successive bangs will produce a warning. When enabled, the object will processing successively, against the state of its parameters when each bang was sent"
        }

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
    seealso = [s.strip() for s in human_data['see-also'].split(',')] if 'see-also' in human_data and human_data['see-also'] else []
    
    # print(seealso)
    discussion = human_data['discussion'] if 'discussion' in human_data else ''
    # client  = 'fluid.{}~'.format(jsonfile.stem.lower())
    client = jsonfile.stem
    attrs = OrderedDict(sorted(attrs.items(), key=lambda t: t[0]))
    
    return {
        'arguments': args, 
        'attributes': attrs, 
        'client': client, 
        'digest':digest, 
        'description': description, 
        'discussion': discussion,
        'seealso': seealso, 
        'module': 'fluid decomposition', 
        'keywords': [], 
        'category': []
    }

def process_template(env,template,extension,outputdir,client_data,namer):
    ofile = outputdir / '{}.{}'.format(namer(client_data['client']),extension)
    template = env.get_template(template)
    with open(ofile,'w') as f:
        f.write(template.render(
            arguments=client_data['arguments'],
            attributes=client_data['attributes'],
            client_name=client_data['client'],
            digest=client_data['digest'],
            description=client_data['description'],
            discussion=client_data['discussion'], 
            seealso = client_data['seealso'] 
            ))

    # #Also return a dictionary summarizing the object for obj-qlookup.json
    # objLookupEntry = {
    #     'digest': digest,
    #     'module':'fluid decomposition',
    #     'keywords':[],
    #     'category': [],
    #     'seealso': seealso
    # }
    # 
    # return objLookupEntry;    
