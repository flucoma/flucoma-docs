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
from collections import OrderedDict,ChainMap
import pprint
import warnings
import inspect
from flucoma.doc import defaults 
from schema import Schema, And,Or, Use, Optional, SchemaError

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
    def __init__(self,Translator=None):
        html4css1.Writer.__init__(self)
        self.translator_class = Translator


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
    return
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
                    upper.append(max_parameter_link(p,allParams[p]))
            else: 
                if cons['upper'] == 'fftFrame':
                    upper.append(host['code_block'].format('(fftSize/2) + 1') + '(see {})'.format(host['parameter_link']('fftSettings',allParams['fftSettings'])))
                if cons['upper'] == 'maxFFTFrame':
                    upper.append(host['code_block'].format('(maxFFTsize/2) + 1') + '(see {})'.format(host['parameter_link']('maxFFTSize',allParams['maxFFTSize'])))
        if 'lower' in cons: 
            if isinstance(cons['lower'],list):
                for p in cons['lower']:
                    lower.append(host['parameter_link'](p,allParams[p]))    
        if 'max' in cons: upper.append(cons['max'])
        if 'min' in cons: lower.append(cons['min'])           
        res = '<h5>Constraints</h5><ul>'
        
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
            if thisAttr['name'] == 'fftSettings': 
                res += '<li> FFTSize, if != -1, will set to the next greatest power of two &gt; 4</li>'
                if 'MaxFFT' in cons: 
                    res += '<li>The maximum manual FFT size is limited to the value of the {} initialization argument</li>'.format(host['parameter_link']('maxFFTSize',allParams['maxFFTSize']))  
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
        'integer': 'int',
        'string': 'symbol',
        'enum':'int', 
        'fft': 'int',
        'dataset':'symbol',
        'labelset':'symbol'
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

    with open(jsonfile.resolve()) as jf:
        raw_data = json.load(jf)
    
    human_data = {}
    human_data_path = yamldir / (jsonfile.stem+'.yaml')    

    if(human_data_path.exists()):
        with open(human_data_path.resolve()) as yf:
            human_data = yaml.load(yf, Loader=yaml.FullLoader)
    else:
        print("WARNING NO HUMAN DOCUMENTATION YET FOR {}".format(jsonfile.stem))            

    return validate_and_merge(jsonfile.stem, raw_data,human_data)

def spy(name,data):
    print(name)
    if data == None or not len(data): 
        print("BURRRRRP")
    return '{o:p}'
    
def validate_and_merge(client, raw_data, human_data):
    args={}
    attrs={}
    messages={}    

    data = raw_data 

    # validate: build up a schema for the YAML based on what's in the JSON 
    param_doc_schema = {'description':str} 
    yaml_schema = {
        'digest':str,
        'sc-categories':str,
        'sc-related':str, 
        'description':str, 
        Optional('discussion'):str, 
        Optional('output'):str, 
        Optional('sc-code'):str, 
        Optional('see-also',default=''):Use(str)
    }
    
    messagedoc_schema = Use(spy)
    
    yaml_params = {
        d['name']:param_doc_schema for d in data['parameters']
    }
        
    if yaml_params.pop('fftSettings', None):
        yaml_params.update({
            n:param_doc_schema for n in ['windowSize', 'hopSize', 'fftSize']                
        })
    
    #make all the parameters optional with a warning generated if missing
    yaml_params = { 
       Optional(k,default=''):v for k,v in yaml_params.items()
    }
        
    if len(yaml_params):
        yaml_schema['parameters'] = yaml_params
    
    yaml_messages = { 
        d['name']:Use(partial(spy,d['name'])) for d in data['messages']
    }
    
    #make all the parameters optional with a warning generated if missing
    # yaml_messages = { 
    #    Optional(k,default=''):v for k,v in yaml_messages.items()
    # }
    
    if len(yaml_messages):
        yaml_schema[Optional('messages')] = yaml_messages
    
    # s = Schema(schema=yaml_schema, ignore_extra_keys = True) 
    # validated = s.validate(human_data)
    
    # merged = dict(ChainMap(data,validated))
    
    # human_data = validated

    data = dict([(d['name'], d) for d in raw_data['parameters']])
    
    if 'parameters' in human_data:
        for k,v in data.items():
            if k != 'fftSettings' and not k in human_data['parameters']:
                print("WARNING CAN'T FIND {} in {}".format(k,client))
                 
    #if there's an empty 'parameters' item in the yaml, just get rid of it 
    # otherwise we have to check for both existence and not None-ness every time
    if 'parameters' in human_data and not human_data['parameters']:
        del human_data['parameters']
        
    
    data['warnings'] = defaults.warningDoc(); 

    if client.lower().startswith('buf'):
        data['blocking'] = defaults.blockingDoc(); 
        data['queue'] = defaults.queueDoc(); 

    for d,v in data.items():
        fixed = False;

        param = {d:v}
        
        if 'parameters' in human_data \
        and d in human_data['parameters']:
            if 'description' in human_data['parameters'][d]:
                param[d].update({'description': human_data['parameters'][d]['description']})
            if 'enum' in human_data['parameters'][d] and 'values' in v:
                param[d]['enum'] = dict(zip(v['values'],human_data['parameters'][d]['enum'].values()))

        if d == 'fftSettings':
            # fftdesc ='FFT settings consist of three numbers representing the window size, hop size and FFT size in samples:\n'
            # if 'parameters' in human_data:
            #     if 'windowSize' in  human_data['parameters']:
            #         fftdesc += '   \n* ' + human_data['parameters']['windowSize']['description'] 
            #     if 'hopSize' in human_data['parameters']:
            #         fftdesc += '   \n* ' + human_data['parameters']['hopSize']['description']
            #     if 'fftSize' in human_data['parameters']:
            #         fftdesc += '   \n* ' + human_data['parameters']['fftSize']['description'] 
            # fftdesc += '\n\n'
            fftdesc = defaults.fftDoc();             
            param[d].update({'description': fftdesc})


        if 'fixed' in v:
            fixed = v['fixed']
        if fixed:
            args.update(param)
        else:
            attrs.update(param)
    
    digest  = human_data['digest'] if 'digest' in human_data else 'A Fluid Decomposition Object'
    description = human_data['description'] if 'description' in human_data else ''
    seealso = [s.strip() for s in human_data['see-also'].split(',')] if 'see-also' in human_data and human_data['see-also'] else []

    discussion = human_data['discussion'] if 'discussion' in human_data else ''

    attrs = OrderedDict(sorted(attrs.items(), key=lambda t: t[0].lower()))

    message_data = OrderedDict([(d['name'], d) for d in raw_data['messages']]) 
    
    if(('input_type' in raw_data) and (raw_data['input_type'] == 'control')):
        message_data['list'] = {
              "args": [],
              "name": "list",
              "returns": "void"
            }
    
    for d,v in message_data.items():
        
        v['args'] = {'arg{}'.format(i):t for i,t in enumerate(v['args'])}
        
        if 'messages' in human_data \
        and d in human_data['messages']:
            if 'description' in human_data['messages'][d]:
                message_data[d].update({'description': human_data['messages'][d]['description']})
            if 'args' in human_data['messages'][d]:
                margs = human_data['messages'][d]['args']
                if margs:
                    arg_names = [a['name'] for a in margs]      
                    arg_data = [a for a in margs]              
                    arg_data = list(filter(lambda a: a['name'] != 'action',arg_data))
                    arg_types = list(v['args'].values())
                    if(len(v['args']) == len(arg_data)): 
                        newargs = {}
                        for i in range(len(arg_data)):
                            if('description' not in arg_data[i]):
                                arg_data[i]['description'] = 'Awaiting documentation'
                            newargs[arg_data[i]['name']] = {'type':arg_types[i],'description':arg_data[i]['description']}
                        message_data[d]['args'] = newargs  
                    else: 
                        print(f'WARNING: {d}: Arg counts don\'t match')

                else: 
                    message_data[d]['args'] = {}
            else: 
                message_data[d]['args'] = {}

        if 'messages' in human_data:
            if d == 'cols' and 'cols' not in human_data['messages']:
                    message_data['cols'] = defaults.colsDoc(); 
                    message_data['cols']['args'] ={}
            if d == 'size' and 'size' not in human_data['messages']:
                    message_data['size'] = defaults.sizeDoc(); 
                    message_data['size']['args'] ={}
            if d == 'clear' and 'clear' not in human_data['messages']:
                    message_data['clear'] = defaults.clearDoc();  
                    message_data['clear']['args'] ={}
        
    messages = message_data

    return {
        'input_type': raw_data['input_type'],
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
    
    # hack for fluid stats, TODO: move to its proper place(s)
    if('input_type' in client_data and client_data['input_type'] == 'control'):
        namer =  lambda n : 'fluid.{}'.format(n.lower())
    else: 
        namer = host['namer'] 
    
    ofile = outputdir / '{}.{}'.format(namer(client_data['client_name']),host['extension'])
    
    ########################################################################  
    # Set up docutils to do RST parsing; here we make 'roles' to generate CCE specific links to other FluCoMa objects or guides
    roles.register_local_role('fluid-obj', fluid_object_role)
    roles.register_local_role('fluid-topic', fluid_topic_role)
    
    ########################################################################  
    # Configure Jinja
    env = Environment(
        loader=FileSystemLoader([template_path]),
        autoescape=select_autoescape(['html', 'xml'])
    )
    
    ########################################################################  
    #    Custom filter functions, invocable with a pipe in jinja templates 
      
    # convert reStructuredText blocks in descriptions etc to the output format for that CCE (html in all cases except SC)
    env.filters['rst'] = partial(rst_filter,translator=host['translator'])
    # generate a properly formatted object name for this CCE
    env.filters['as_host_object_name'] = namer
    # lookup a type name for this CCE
    env.filters['typename'] = host['types']
    # generate parameter constraints text for this CCE
    env.filters['constraints'] = partial(constraints,host=host)
    # determine if the object in question is part of the CLI distribution (in order to filter out stuff from see-also)
    env.tests['incli'] = lambda s: s.lower().startswith('buf')
    
    ########################################################################  
    # run jinja on template for this host 
    
    template = env.get_template(host['template'])
    
    with open(ofile,'w', newline='\n') as f:
        f.write(template.render(client_data))
            # arguments=client_data['arguments'],
            # attributes=client_data['attributes'],
            # messages=client_data['messages'],
            # client_name=client_data['client'],
            # digest=client_data['digest'],
            # description=client_data['description'],
            # discussion=client_data['discussion'], 
            # seealso = client_data['seealso'] 
            # ))
    return client_data; 

def process_topic(topic_file,template_path,outputdir,host):
    ofile = outputdir / '{}.{}'.format(Path(host['topic_subdir']) / Path(topic_file.stem),host['topic_extension'])    
    
    (outputdir / Path(host['topic_subdir'])).mkdir(exist_ok=True)
    
    # print(ofile)
    # roles.register_local_role('fluid_object', fluid_object_role)
    roles.register_local_role('fluid-obj', fluid_object_role)
    roles.register_local_role('fluid-topic', fluid_topic_role)
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
        with open(topic_file.resolve()) as f:
            topic_data = yaml.load(f, Loader=yaml.FullLoader)
    else: 
        raise NameError('{} not found'.format(topic_file))
    
    with open(ofile,'w', newline='\n') as f:
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
