from flucoma.doc import data 

from flucoma.doc.rst import parse_object

import glob
from pathlib import Path
import yaml 
import io
import os 
import textwrap
from pprint import pprint,pformat 
import sys
import json
# import docutils.nodes
# from docutils.parsers import rst
# 
# import docutils.utils
# import docutils.frontend
# from docutils import nodes
# 
# from docutils.parsers.rst.states import Inliner 
import re
from difflib import Differ,unified_diff,ndiff

def compare(old,new):
    
    def prefilter(line):
        # return re.sub('\s+',' ',reallystrip(line))
        return reallstrip(line)
    
    new_lines = new.splitlines(True)
    old_lines = old.splitlines(True)
    d = Differ(linejunk=lambda x: len(reallystrip(x)) == 0, 
    charjunk=lambda x: x.isspace()) 
    # dif = filter(lambda x: not x.startswith('  '),
    # dif = d.compare([prefilter(x) for x in old_lines],[prefilter(x) for x in new_lines])
    # )
    dif = list(filter(lambda x: not x.startswith('  '),d.compare(
        # old_lines,new_lines
        [reallystrip(x) for x in old_lines],[reallystrip(x) for x in new_lines]
    )))
    if dif: 
        if(len(dif)): pprint(dif)
        # sys.stdout.writelines(list(dif))

def reallystrip(string):
    return string.strip().strip(u'\u200B\ufeff')

def message(name,m,stream):
    desc = m.get('description',None)
    args = m.get('args',[])    
    # print(f"\n.. message:: {reallystrip(name)}",file=stream)
    print(f"\n:message {reallystrip(name)}:",file=stream)
    
    args = args if args else []

    for a in args: 
        arg_desc = a.get('description','')
        arg_name = a.get('name','Unamed Argument Badness Scenario')
        print(f"\n{' ' * 3}:arg {reallystrip(arg_name)}: {reallystrip(arg_desc)}",file=stream)
    if(desc): 
        print(f"\n{textwrap.indent(reallystrip(desc),' ' * 3)}",file = stream)
        # print(f'\n    {desc}\n',file=stream)
    
def control(name,m,stream): 
    try:
        desc = m.get('description',None)   
    except AttributeError: 
        print("BAD CONTROL",name)
        m = {'description':m }
        desc = m
    # print(f".. control:: {reallystrip(name)}",file=stream)
    print(f":control {reallystrip(name)}:",file=stream)
    
    
    if(desc): 
        print(f"\n{textwrap.indent(reallystrip(desc),' ' * 3)}\n",file = stream)
        
    enum = m.get('enum',None)    
    if(enum):
        print(f"{' ' * 3}:enum:\n",file=stream)
        for k,v in enum.items():
            print(f"{' ' * 6}:{k}:",file=stream)
            print(f"{textwrap.indent(reallystrip(v),' ' * 9)}\n",file=stream)

def main(basepath):
    basepath = Path(basepath)
    
    filelist = basepath.glob('*.yaml')
        
    for thisfile in filelist:
        with open(thisfile,'r') as f: 
            ostream = io.StringIO()
            d = yaml.load(f, Loader=yaml.FullLoader)   
            print('Converting object', thisfile)     
            controls = d.pop('parameters',{})    
            messages = d.pop('messages',{})    
            d.pop('sc-code',None)
            # print(json.dumps(messages,indent=4))
            keys = [(k,v) for k,v in d.items()]
            
            for k,v in keys: 
                v = reallystrip(v) if v else ''                
                if len(v.splitlines(True)) > 1:
                    v = '\n' + textwrap.indent(v,' ' * 3) + '\n'                  
                print(f":{reallystrip(k)}: {v}", file=ostream)   

            if(messages is None): messages = {}
            if(controls is None): controls = {}
                        
            print('\n',file=ostream)
            # print(json.dumps(obj,indent=4)) 
            controls.pop('server',None)
            
            for name,data in controls.items(): control(name,data,ostream) 
            for name,data in messages.items(): message(name,data,ostream)
            
            # print(ostream.getvalue())
            obj = parse_object.parse(ostream.getvalue())
            
            rstpath = (basepath / '..' / 'rst').resolve()
            rstpath.mkdir(exist_ok=True)
            newfile = rstpath / Path((Path(thisfile).stem + '.rst'))
            # print(newfile)
            with open(newfile,'w') as f2: 
                f2.write(ostream.getvalue())
                    
            d['messages'] = messages
            d['parameters'] = controls
            # 
        
            for k,v in d.items():
                if isinstance(v,str):            
                    try: 
                        # diff = \
                        compare(v,obj[k])
                    except KeyError: 
                        json.dumps(obj,indent=4)
            
                    # if len(diff):
                    #     print(k)
                    #     # sys.stdout.writelines(diff) 
                    #     print(diff)
            
            for c,v in controls.items():
                try:                           
                    new_v = obj['parameters'][c] 
                except KeyError as e: 
                    print(e)
                    print(json.dumps(obj['paraemters'],indent=4))     
            
                print('Comparing control', c)   
                
                # dif = 
                compare(v['description'],new_v['description']) 
                # if(len(dif)): pprint(dif)
            
            for m,v in messages.items():  
                try:                           
                    new_v = obj['messages'][m] 
                except KeyError as e: 
                    print(e)
                    print(json.dumps(obj['messages'],indent=4))
            
                print('Comparing message', m)
            
                # dif = 
                compare(v['description'],new_v['description'])
                # if(len(dif)):pprint(dif)
            
                if v.get('args',None):
                    assert(new_v['args'] is not None)                    
                    old_args = v.get('args')
                    if old_args[0]['name'] == 'server':
                        old_args.remove(old_args[0])
                    try:    
                        assert(len(old_args) == len(new_v['args']))    
                    except AssertionError:
                        pprint(json.dumps(old_args),indent=4)
                        pprint(json.dumps(new_v['args']),indent=4)
            
                    for i,a in enumerate(old_args):
                        # dif = 
                        compare(
                            a['description'],
                            new_v['args'][i]['description']
                        )                        
                        # if(len(dif)): pprint(dif)


if __name__ == '__main__':
    # argv[1] needs to be the path to flucoma-docs/docs
    main(sys.argv[1])
