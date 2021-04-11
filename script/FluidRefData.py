# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from docutils.core import publish_parts
from docutils.parsers.rst import roles,directives
from docutils.parsers.rst import Directive
from docutils.writers import html4css1
from docutils import nodes, utils
from jinja2 import Template, Environment, PackageLoader, FileSystemLoader, select_autoescape, Markup
from functools import partial
from pathlib import Path
import json
import yaml
import re
from collections import OrderedDict
import pprint
import warnings
import inspect

def fluid_object_role(role, rawtext, text, lineno, inliner,
                       options={}, content=[]):
    """Create a link to a FluCoMa object
    """
    options['flucoma'] = 1
    roles.set_classes(options)
    node = nodes.reference(rawtext,utils.unescape(text), **options)
    return [node], []

def fluid_topic_role(role, rawtext, text, lineno, inliner,
                       options={}, content=[]):
    """Create a link to a FluCoMa topic
    """
    print('topic {}'.format(rawtext))
    options['flucoma'] = 1
    roles.set_classes(options)
    node = nodes.reference(rawtext,utils.unescape(text), **options)
    return [node], []



class MaxBufferSubstitution(Directive):
    
    required_arguments = 0 
    optional_arguments = 0 
    
    def run(self):
        node = nodes.reference("buffer~","buffer~")
        return [node]
        # reference = directives.uri(self.arguments[0])
        # self.options['uri'] = reference
        # image_node = nodes.image(rawsource=self.block_text,
        #                          **self.options)
        # return [image_node]
    

class MaxHTMLTranslator(html4css1.HTMLTranslator):
    """docutils translator for Max ref    
    """    
    def visit_reference(self,node):
        if('flucoma' in node):
           node[:] = [nodes.raw('',max_name(node.astext()),format='html')]
           self.body.append(self.starttag(node, 'o', ''))
        else:
            super().visit_reference(node)
    
    def depart_reference(self,node):
        if('flucoma' in node):
            self.body.append('</o>')
        else: 
            super().depart_reference(node)

class PDHTMLTranslator(html4css1.HTMLTranslator):
    """docutils translator for PD ref    
    """    
    def visit_reference(self,node):    
        atts = {'class' : 'fluid_object'}    
        if('flucoma' in node):
            pdname = pd_name(node.astext())  
            node[:] = [nodes.raw('',pdname,format='html')]
            atts['href'] = pdname + '.html'
            self.body.append(self.starttag(node, 'a', '',**atts))
            # print(inspect.getmembers(node))
        else:
            super().visit_reference(node)
    
class CLIHTMLTranslator(html4css1.HTMLTranslator):
    """docutils translator for PD ref    
    """    
    
    _skip_one = False; 
    
    def visit_reference(self,node):    
        atts = {'class' : 'fluid_object'}    
        if('flucoma' in node):
            #if it's not a Buf* star object, don't link to it (or mention it)
            if not node.astext().startswith('Buf'):
                node.remove(node.astext())                
                self._skip_one = True                
                return 
            self._skip_one = False
            cli = cli_name(node.astext())  
            node[:] = [nodes.raw('',cli,format='html')]
            atts['href'] = cli + '.html'            
            self.body.append(self.starttag(node, 'a', '',**atts))
            # print(inspect.getmembers(node))
        else:
            super().visit_reference(node)
            
    def depart_reference(self,node):
        if(not 'flucoma' in node) or ('flucoma' in node and not self._skip_one):
            super().depart_reference(node) 


class FluidHTMLWriter(html4css1.Writer):
    """docutils writer for Max ref
    """    
    def __init__(self,Writer=None):
        html4css1.Writer.__init__(self)
        self.translator_class = Writer


def rst_filter(s,translator,**kwargs):    
    if s is None or len(s) == 0:
         return ''
    
    s += "\n\n.. |buffer| replace:: buffer~\n"     
         
    settings = {'report_level':1}
    if(kwargs):
        settings = kwargs['settings']         
    return Markup(publish_parts(source=s, writer=FluidHTMLWriter(translator),settings_overrides=settings)['html_body'])

def max_type(value):
    type_map = {
        'float':'float64',
        'long': 'int',
        'buffer':'symbol',
        'integer': 'int',
        'string': 'symbol',
        'enum':'int', 
        'fft': 'int',
        'dataset':'symbol',
        'labelset':'symbol'
    }
    return type_map[value] if value in type_map else 'UNKNOWN({})'.format(value)

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
            res += '<li>Two amplitude + frequency pairs. Amplitudes are unbounded, frequencies in range 0-1</li>'    
        try:        
            if thisAttr['name'].lower() == 'fftsettings': 
                res += '<li> FFTSize, if != -1, will set to the next greatest power of two &gt; 4</li>'
                if 'MaxFFT' in cons: 
                    res += '<li>The maximum manual FFT size is limited to the value of the {} initialization argument</li>'.format(host['parameter_link']('maxFFTSize',allParams['maxFFTSize'.lower()]))  
                res += '<li>if FFT size != -1, then window size is clipped at FFT size</li>'
        except KeyError: 
            pass
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
    raw_data = json.load(open(jsonfile.resolve()))
    human_data = {}
    human_data_path = yamldir / (jsonfile.stem+'.yaml')    
    if(human_data_path.exists()):
        human_data = yaml.load(open(human_data_path.resolve()), Loader=yaml.FullLoader)
    else:
        print("WARNING NO HUMAN DOCUMENTATION YET FOR {}".format(jsonfile.stem))            
        # print(human_data['digest'])
    # print(human_data)
    args={}
    attrs={}
    messages={}    
    # data = data['parameters'] #data is in json array to preserve order,
    data = OrderedDict([(d['name'], d) for d in raw_data['parameters']]) 
    if 'parameters' in human_data:
        for k,v in data.items():
            if k != 'fftSettings' and not k in human_data['parameters']:
                print("WARNING CAN'T FIND {} in {}".format(k,jsonfile.stem))
    # else: 
    #     print("WARNING NO HUMAN DOCUMENTATION YET FOR {}".format(jsonfile.stem))            
    
    data = {k.lower():v for k,v in data.items()}  
    
    #if there's an empty 'parameters' item in the yaml, just get rid of it 
    # otherwise we have to check for both existence and not None-ness every time
    if 'parameters' in human_data and not human_data['parameters']:
        del human_data['parameters']
        
    if 'parameters' in human_data and human_data['parameters']:
        human_data['parameters'] = {k.lower():v for k,v in human_data['parameters'].items()}

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

        if 'parameters' in human_data \
        and d in human_data['parameters']:
            if 'description' in human_data['parameters'][d.lower()]:
                param[d.lower()].update({'description': human_data['parameters'][d]['description']})
            if 'enum' in human_data['parameters'][d.lower()] and 'values' in v:
                param[d.lower()]['enum'] = dict(zip(v['values'],human_data['parameters'][d]['enum'].values()))

        if d.lower() == 'fftsettings':
            fftdesc ='FFT settings consist of three numbers representing the window size, hop size and FFT size in samples:\n'
            if 'parameters' in human_data:
                if 'windowSize' in  human_data['parameters']:
                    fftdesc += '   \n* ' + human_data['parameters']['windowSize']['description'] 
                    #+ ' . Window size can be any integer (in samples), but is clipped at its upper range by the FFT size (when this is not -1)'
                if 'hopSize' in human_data['parameters']:
                    fftdesc += '   \n* ' + human_data['parameters']['hopSize']['description']
                    # + '. The default of -1 sets the hop size to window size / 2. However it can be *any* size (although some small integer fraction of the window size is conventional).'
                if 'fftSize' in human_data['parameters']:
                    fftdesc += '   \n* ' + human_data['parameters']['fftSize']['description'] 
                    #+ '. The default of -1 sets the FFT size to the nearest power of 2 equal to or above the window size. When set manually, it will always snap internally to the next power of two, and can not be smaller than the window size. When greater than the window size, the input frame is zero-padded.'
            fftdesc += '\n\n'
            
            fftDefault = 'The hop size and fft size can both be set to -1 (and are by default), with slightly different meanings:\n   \n* For the hop size, -1 = ``windowSize/2``\n* For the FFT size, -1 = ``windowSize`` snapped to the nearest equal / greater power of 2 (e.g. ``windowSize 1024`` => ``fftSize 1024``, but ``windowsSize 1000`` also => ``fftSize 1024``)\n'
            
            fftdesc += fftDefault
            
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

    discussion = human_data['discussion'] if 'discussion' in human_data else ''
    # client  = 'fluid.{}~'.format(jsonfile.stem.lower())
    client = jsonfile.stem
    attrs = OrderedDict(sorted(attrs.items(), key=lambda t: t[0]))


    message_data = OrderedDict([(d['name'].lower(), d) for d in raw_data['messages']]) 
    
    if 'messages' in human_data and human_data['messages']:
        human_data['messages'] = {k.lower():v for k,v in human_data['messages'].items()}
    
    # some things will happen here
    for d,v in message_data.items():
        
        v['args'] = {'arg{}'.format(i):t for i,t in enumerate(v['args'])}
        
        if 'messages' in human_data \
        and d in human_data['messages']:
            if 'description' in human_data['messages'][d.lower()]:
                message_data[d.lower()].update({'description': human_data['messages'][d.lower()]['description']})
            # print(v['args'])
            if 'args' in human_data['messages'][d.lower()]:
                margs = human_data['messages'][d.lower()]['args']
                if margs:
                    arg_names = [a['name'] for a in margs]      
                    arg_data = [a for a in margs]              
                    # print(arg_data)
                    arg_data = list(filter(lambda a: a['name'] != 'action',arg_data))
                    # print(arg_data)
                    # try:                         
                    #     arg_names.remove('action')
                    # except ValueError: 
                    #     pass #if it's not there, move on
                    # print(len(v['args']), len(arg_names),arg_names)
                    arg_types = list(v['args'].values())
                    # print(v['args'])
                    if(len(v['args']) == len(arg_data)): 
                        newargs = {}
                        for i in range(len(arg_data)):
                            if('description' not in arg_data[i]):
                                arg_data[i]['description'] = 'Awaiting documentation'
                            newargs[arg_data[i]['name']] = {'type':arg_types[i],'description':arg_data[i]['description']}
                        message_data[d.lower()]['args'] = newargs  
                        # print(newargs)                  
                    else: 
                        print("WARNING: Arg counts don't match")
                else: 
                    message_data[d.lower()]['args'] = {}
            else: 
                message_data[d.lower()]['args'] = {}
                    # print(human_data['messages'][d.lower()]['args'])
        if 'messages' in human_data:
            if d.lower() == 'cols' and 'cols' not in human_data['messages']:
                    message_data['cols'] = {
                        'description': 'The number of columns (dimensions) in this model or dataset / labeset', 
                        'args':{},                        
                    }
            if d.lower() == 'size' and 'size' not in human_data['messages']:
                    message_data['size'] = {
                        'description': 'The number of data points (entries / observations) in this model or dataset / labeset', 
                        'args':{},                        
                    }
            if d.lower() == 'clear':
                if 'clear' not in human_data['messages']:
                    message_data['clear'] = {
                        'description': 'Resets the internal state of the model', 
                        'args':{},                        
                    }
                    message_data['clear']['args'] = {}   
        
    messages = message_data
    # print(messages)
    return {
        'arguments': args, 
        'attributes': attrs, 
        'messages':messages,
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
            'code_block': '<m>{}</m>', 
            'translator': MaxHTMLTranslator, 
            'topic_extension': 'maxvig.xml', 
            'topic_subdir': 'vignettes',
            'topic_template':'maxvig.xml'
        },
        'pd':{
            'namer':pd_name, 
            'template': 'pd_htmlref.html',
            'extension': 'html', 
            'types': pd_type,
            'glob': '**/*.json', 
            'parameter_link': plain_parameter_link, 
            'code_block': '<code>{}</code>', 
            'translator': PDHTMLTranslator,
            'topic_extension': 'html', 
            'topic_subdir': '',
            'topic_template':'pd_htmltopic.html'
        }, 
        'cli':{
            'namer':cli_name, 
            'template': 'cli_htmlref.html',
            'extension': 'html', 
            'types': cli_type,
            'glob': '**/Buf[!Compose]*.json', 
            'parameter_link': plain_parameter_link, 
            'code_block': '<code>{}</code>', 
            'translator': CLIHTMLTranslator,
            'topic_extension': 'html', 
            'topic_subdir': '',
            'topic_template':'cli_htmltopic.html'
        }
    }

def process_template(template_path,outputdir,client_data,host):
    ofile = outputdir / '{}.{}'.format(host['namer'](client_data['client']),host['extension'])
    # print(host['namer'](client_data['client']))
    roles.register_local_role('fluid-obj', fluid_object_role)
    roles.register_local_role('fluid-topic', fluid_topic_role)
    # directives.register_directive('buffer', MaxBufferSubstitution)
    env = Environment(
        loader=FileSystemLoader([template_path]),
        autoescape=select_autoescape(['html', 'xml'])
    )
    env.filters['rst'] = partial(rst_filter,translator=host['translator'])
    env.filters['as_host_object_name'] = host['namer']
    env.filters['typename'] = host['types']
    env.filters['constraints'] = partial(constraints,host=host)
    env.tests['incli'] = lambda s: s.lower().startswith('buf')
    template = env.get_template(host['template'])
    with open(ofile,'w') as f:
        f.write(template.render(
            arguments=client_data['arguments'],
            attributes=client_data['attributes'],
            messages=client_data['messages'],
            client_name=client_data['client'],
            digest=client_data['digest'],
            description=client_data['description'],
            discussion=client_data['discussion'], 
            seealso = client_data['seealso'] 
            ))
    return client_data; 

def process_topic(topic_file,template_path,outputdir,host):
    ofile = outputdir / '{}.{}'.format(Path(host['topic_subdir']) / Path(topic_file.stem),host['topic_extension'])    
    
    (outputdir / Path(host['topic_subdir'])).mkdir(exist_ok=True)
    
    
    
    # print(ofile)
    roles.register_local_role('fluid_object', fluid_object_role)
    env = Environment(
        loader=FileSystemLoader([template_path]),
        autoescape=select_autoescape(['html', 'xml'])
    )
    env.filters['rst'] = partial(rst_filter,translator=host['translator'],settings={'initial_header_level':2})
    env.filters['as_host_object_name'] = host['namer']
    env.filters['typename'] = host['types']
    # env.filters['constraints'] = partial(constraints,host=host)
    env.tests['incli'] = lambda s: s.lower().startswith('buf')
    template = env.get_template(host['topic_template'])
    
    topic_data = {}          
    if(topic_file.exists()):
        topic_data = yaml.load(open(topic_file.resolve()), Loader=yaml.FullLoader)
    else: 
        raise NameError('{} not found'.format(topic_file))
    
    with open(ofile,'w') as f:
        f.write(template.render(
            title=topic_data['title'],
            digest=topic_data['digest'],
            description=topic_data['description'],
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
