from docutils.core import publish_parts
from jinja2 import Template, Environment, PackageLoader, FileSystemLoader, select_autoescape, Markup
from functools import partial
import json
import yaml
import re
from collections import OrderedDict
import pprint

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

def max_parameter_link(name,bits):
    return "<at>{}</at>".format(name.lower()) if bits['fixed'] == True else "<at>{}</at>".format(name.lower())

def plain_parameter_link(name,bits): 
    return "<code>{}</code>".format(name.lower())

def constraints(thisAttr,allAttrs,allArgs,host):
    upper = []
    lower = []
    snaps = {
        'powerTwo':'powers of two', 
        'odd': 'odd numbers'
    }
    allParams = {}
    allParams.update(allAttrs)
    allParams.update(allArgs)
    if 'constraints' in thisAttr:
        cons = thisAttr['constraints']
        if 'upper' in cons:
            if isinstance(cons['upper'],list):
                for p in cons['upper']:
                    # pprint.pprint(allParams)
                    upper.append(max_parameter_link(p,allParams[p.lower()]))
            else: 
                if cons['upper'] == 'fftFrame':
                    upper.append(host['code_block'].format('(fftSize/2) + 1') + '(see {})'.format(host['parameter_link']('fftSettings',allParams['fftSettings'.lower()])))
                if cons['upper'] == 'maxFFTFrame':
                    upper.append(host['code_block'].format('(maxFFTsize/2) + 1') + '(see {})'.format(host['parameter_link']('maxFFTSize',allParams['maxFFTSize'.lower()])))
        if 'lower' in cons: 
            if isinstance(cons['lower'],list):
                for p in cons['lower']:
                    lower.append(host['parameter_link'](p,allParams[p.lower()]))    
        if 'max' in cons: upper.append(cons['max'])
        if 'min' in cons: lower.append(cons['min'])           
        res = '<h4>Constraints</h4><ul>'
        
        if len(lower) > 1: 
            res += '<li>Minimum: MAX({})</li>'.format(','.join(map(str,lower)))
        elif len(lower) == 1: 
            res += '<li>Minimum: {}</li>'.format(lower[0])
    
        if len(upper) > 1: 
            res += '<li>Maximum: MIN({})</li>'.format(','.join(map(str,upper)))
        elif len(upper) == 1: 
            res += '<li>Maximum: {}</li>'.format(upper[0])
            
        if 'snap' in cons:
            res += '<li>Snaps to {}</li>'.format(snaps[cons['snap']])
        if 'FreqAmpPair' in cons:
            res += '<li>Two linear amplitude + normlaised frequency pairs. Amplitudes unbounded, frequencies in range 0-1</li>'    
        res += '</ul>'
        # print(Markup(res))    
        return Markup(res)
    else:
        return ''
    
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
    return 'fluid-{}'.format(value.lower().split('buf')[1])    

def process_client_data(jsonfile, yamldir):
    print('Processing reference data for {}'.format(jsonfile.stem))
    # template = env.get_template('maxref.xml')
    data = json.load(open(jsonfile.resolve()))
    human_data = {}
    human_data_path = yamldir / (jsonfile.stem+'.yaml')    
    if(human_data_path.exists()):
        human_data = yaml.load(open(human_data_path.resolve()), Loader=yaml.FullLoader)
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


host_vars = {
        'max': {
            'namer':max_name, 
            'template': 'maxref.xml',
            'extension': 'maxref.xml',
            'types': max_type,
            'glob': '**/*.json', 
            'parameter_link': max_parameter_link, 
            'code_block': '<m>{}</m>'
        },
        'pd':{
            'namer':pd_name, 
            'template': 'pd_htmlref.html',
            'extension': 'html', 
            'types': pd_type,
            'glob': '**/*.json', 
            'parameter_link': plain_parameter_link, 
            'code_block': '<code>{}</code>'
        }, 
        'cli':{
            'namer':cli_name, 
            'template': 'cli_htmlref.html',
            'extension': 'html', 
            'types': cli_type,
            'glob': '**/Buf[!Compose]*.json', 
            'parameter_link': plain_parameter_link, 
            'code_block': '<code>{}</code>'
        }
    }

def process_template(template_path,outputdir,client_data,host):
    ofile = outputdir / '{}.{}'.format(host['namer'](client_data['client']),host['extension'])
    print(host['namer'](client_data['client']))
    env = Environment(
        loader=FileSystemLoader([template_path]),
        autoescape=select_autoescape(['html', 'xml'])
    )
    env.filters['rst'] = rst_filter 
    env.filters['as_host_object_name'] = host['namer']
    env.filters['typename'] = host['types']
    env.filters['constraints'] = partial(constraints,host=host)
    env.tests['incli'] = lambda s: s.lower().startswith('buf')
    template = env.get_template(host['template'])
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
