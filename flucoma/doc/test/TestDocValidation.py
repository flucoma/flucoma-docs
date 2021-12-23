# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import unittest
import copy
from flucoma.doc.validate.controls import validate_controls
from flucoma.doc.validate.messages import validate_messages      
from flucoma.doc.validate.object import validate_object,merge_object
from  flucoma.doc.validate.common import not_yet_documented
from ..defaults import DefaultMessageDocs
from flucoma.FluidRefData import process_client_data
from ..legacy.adaptor import make_it_like_it_was

# from pprint import pprint,pformat
# from collections import ChainMap

from pathlib import Path
import json
import yaml
# from difflib import * 


generated_test_controls  = [{
    'name':'control1',
    'displayName':'Control One', 
    'type':'long',
    'default':0, 
    'size':1, 
    'fixed':False,
    'constraints':{}
},{
    'name':'control2',
    'displayName':'Control Two', 
    'type':'buffer',
    'default':0, 
    'size':1, 
    'fixed':False,
    'constraints':{'min':1,'max':0}
}]

human_data_complete = {
    'control1':{
        'description':'foo'
    },
    'control2':{
        'description':'bar'
    }
} 

generated_test_messages = [{
    "args": [
        "DataSet",
        "integer"
    ],
    "name": "merge",
    "returns": "void"
},{
    "args": [],
    "name": "dump",
    "returns": "string"
}]

human_message_data_complete = {
    'merge':{
        'description': 'I merge',
        'args':[
            {'name': 'ds', 'description':'A ds'},
            {'name': 'as', 'description': 'an int'}
        ]
    },
    'dump':{
        'description': 'I dump',
        'args':[]    
    }
}

empty_message_data_response ={ 
    'merge':{
        'description': not_yet_documented,
        'args':[
            {
                'name':not_yet_documented,
                'description':not_yet_documented
            },
            {
                'name':not_yet_documented,
                'description':not_yet_documented
            }
        ]
    },
    'dump':{
        'description': not_yet_documented,
        'args':[]    
    }
}

class TestValidateDocs(unittest.TestCase):

    # def test_top_level(self):
    #     justManditory = {
    #         'digest': 'some text',
    #         'sc-categories': 'some categories',
    #         'sc-related': 'some objects',
    #         'description': 'some blurb'
    #     }
    # 
    #     self.assertEqual(validate_object(justManditory), True)
    # 
    #     withOptions = dict(ChainMap(justManditory, {
    #         'discussion': '',
    #         'output': '',
    #         'sc-code': '',
    #         'see-also': None
    #     }))
    # 
    #     self.assertEqual(validate_object(withOptions), True)
        
    # def test_generated_controls(self):
    #     self.assertEqual(validate_generated_data(generated_test_controls), generated_test_controls)

    def test_valid_controls(self):           
        self.assertEqual(
            human_data_complete,
            validate_controls(generated_test_controls,human_data_complete) 
        )
    
    def test_empty_controls(self):
        human_data_empty = {} #should still return something valid!
        human_data_filled_in =  copy.deepcopy(human_data_complete)
        
        for k in human_data_complete.keys():
            human_data_filled_in[k]['description'] = not_yet_documented
        
        self.assertEqual(
            human_data_filled_in, validate_controls(generated_test_controls,human_data_empty)
        )
    
    def test_controls_missing_description(self):
        human_data_missing_desc = copy.deepcopy(human_data_complete)
        human_data_missing_desc['control1'].pop('description')
        
        human_data_missing_desc_filled = copy.deepcopy(human_data_complete)
        
        human_data_missing_desc_filled['control1'] = {      
            'description':not_yet_documented
        }
                
        self.assertEqual(
            human_data_missing_desc_filled,
            validate_controls(generated_test_controls,human_data_missing_desc)
        )
    
    def test_default_control_lookup(self):
        lookup = {
            'control1': 'foo'
        }
        
        human_data_missing_desc = copy.deepcopy(human_data_complete)
        human_data_missing_desc['control1'].pop('description')
        
        human_data_missing_with_default = copy.deepcopy(human_data_complete)
        human_data_missing_with_default['control1']['description'] = 'foo'
        
        self.assertEqual(
            human_data_missing_with_default,
            validate_controls(generated_test_controls,
                              human_data_missing_desc,
                              defaults_lookup=lookup
                             )
        )
        
        
    def test_valid_message(self):
        self.assertEqual(human_message_data_complete,
                         validate_messages(
                                generated_test_messages,
                                human_message_data_complete
                        )
        )
    
    def test_empty_message(self):
    
        self.assertEqual(empty_message_data_response,
                             validate_messages(
                                    generated_test_messages,
                                    {}
                            )
        )   
        
    def test_message_missing_args(self):
        
        test_input = copy.deepcopy(human_message_data_complete) 
        test_input['merge']['args'][0]['description'] = None
        
        test_output = copy.deepcopy(human_message_data_complete) 
        test_output['merge']['args'][0]['description'] = not_yet_documented
        
        self.assertEqual(test_output,validate_messages(generated_test_messages,test_input))
        
        test_input['merge']['args'][0].pop('description')
        
        self.assertEqual(test_output,validate_messages(generated_test_messages,test_input))
        
        test_input['merge']['args'][0].pop('name')
        test_output['merge']['args'][0]['name'] = not_yet_documented
        
        self.assertEqual(test_output,validate_messages(generated_test_messages,test_input))
        
        test_input['merge']['args'].pop()
        test_output['merge']['args'][1]['name'] = not_yet_documented
        test_output['merge']['args'][1]['description'] = not_yet_documented
        
        self.assertEqual(test_output,validate_messages(generated_test_messages,test_input))
        
    def test_message_lookup(self):
        
        generated_data = copy.deepcopy(generated_test_messages)
        generated_data += [{
            "args": [],
            "name": "cols", 
            "returns": "integer"
        }]
        
        test_input = copy.deepcopy(human_message_data_complete)
        
        test_output = copy.deepcopy(human_message_data_complete)        
        test_output['cols'] = DefaultMessageDocs['cols']
        
        self.assertEqual(test_output,validate_messages(generated_data,test_input))

    def test_merge(self):
        
        client = 'HPSS'
        
        yolde = process_client_data(
            Path(f'/Users/owen/dev/flucoma-docs/build/json/{client}.json'),
            Path('/Users/owen/dev/flucoma-docs/doc/')
        )
        
        with open(f'/Users/owen/dev/flucoma-docs/build/json/{client}.json','r') as f:
            fullobj = json.load(f)
    
        with open(f'/Users/owen/dev/flucoma-docs/doc/{client}.yaml','r') as f:
            human = yaml.load(f,Loader=yaml.FullLoader)    
        
        # controls = fullobj['parameters']
        
        # ctrls = validate_controls(controls,human['parameters'])
        # 
        # for k in ctrls.keys(): 
        #     print(k)
        # 
        # print('\n\nCurrent')
        # for k in yolde['attributes']: 
        #     print(k)
        # 
        # print('\n')
        # for k in yolde['arguments']: 
        #     print(k)
        # 
        # if(len(fullobj['messages'])):
        #     msgs = validate_messages(fullobj['messages'],human['messages'])
        # else 
        #     msgs = []
        
        gen,hum =  validate_object(fullobj,human)
        # 
        # pprint(gen)
        # pprint(hum)
        # 
        merged = merge_object(gen,hum)
        # pprint(merged)
        # print('\n\n\n')
        # pprint(yolde)
        # 
        merged = make_it_like_it_was(client,merged)
        
        # print('\n\n\n')
        # pprint(yolde)
        
        for k, v in yolde.items(): 
            print(k)
            if k != 'attributes':
                matches = v == merged[k]
            else: 
                matches = True 
                print('===========HERE-===')                
                for d in v: 
                    print(d)
                    olddesc = v[d]['description']
                    newdesc = merged[k][d]['description']
                    if olddesc != newdesc: 
                        matches = False 
                        print('=====old desc')
                        print(olddesc)
                        print('=====new desc')
                        print(newdesc)
                         
            print(f'yolde[{k}] matches new[{k}] is {matches}')
            # if not matches: 
            #     a = pformat(v,sort_dicts=False)
            #     b = pformat(merged[k],sort_dicts=False)
            # 
                    
        return True
    # 
    # def test_object(self):
    #     generated_data = {}
    #     generated_data['parameters'] = copy.deepcopy(generated_control_data)
    #     generated_data['messages'] = copy.deepcopy(generated_control_data)
    
    

if __name__ == '__main__':
    unittest.main()
