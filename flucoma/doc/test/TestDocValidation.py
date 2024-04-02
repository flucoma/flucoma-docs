# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import unittest
import copy
from pathlib import Path
import json
import yaml
import logging

from flucoma.doc.validate.controls import validate_controls, render_constraints_markup
from flucoma.doc.validate.messages import validate_messages      
from flucoma.doc.validate.object import validate_object
from flucoma.doc.validate.common import not_yet_documented
from ..defaults import DefaultMessageDocs
from flucoma.FluidRefData import process_client_data
from ..transformers import default_transform

from .data import generated_test_controls, human_data_complete, generated_test_messages,human_message_data_complete,empty_message_data_response

class TestValidateDocs(unittest.TestCase):
    
    @classmethod
    def setUpClass(cls):
        logging.getLogger().addHandler(logging.NullHandler())
    
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
        
        input = copy.deepcopy(generated_test_controls)
        input[1]['constraints'] = {} #skip constraints for now     
        self.assertEqual(
            human_data_complete,
            validate_controls(input,human_data_complete) 
        )
    
    def test_empty_controls(self):
        human_data_empty = {} #should still return something valid!
        human_data_filled_in =  copy.deepcopy(human_data_complete)
        
        for k in generated_test_controls: 
            human_data_filled_in[k['name']] ['description'] = not_yet_documented + render_constraints_markup(k)
        
        # for k in human_data_complete.keys():
        #     human_data_filled_in[k]['description'] = not_yet_documented
        
        self.assertEqual(
            human_data_filled_in, validate_controls(generated_test_controls,human_data_empty)
        )
    
    def test_controls_missing_description(self):
        human_data_missing_desc = copy.deepcopy(human_data_complete)
        human_data_missing_desc['control1'].pop('description')
        
        human_data_missing_desc_filled = copy.deepcopy(human_data_complete)
        
        human_data_missing_desc_filled['control1'] = {      
            'description':not_yet_documented + render_constraints_markup(
                generated_test_controls[0]
            )
        }
        
        c2outdesc = human_data_missing_desc_filled['control2']['description'] + render_constraints_markup(generated_test_controls[1]) 
        human_data_missing_desc_filled['control2']['description'] = c2outdesc
                
        self.assertEqual(
            human_data_missing_desc_filled,
            validate_controls(generated_test_controls,human_data_missing_desc)
        )
    
    def test_default_control_lookup(self):
        lookup = {
            'controls':{'control1': {'description': 'foo'}}
        }
        
        human_data_missing_desc = copy.deepcopy(human_data_complete)
        human_data_missing_desc['control1'].pop('description')
        
        human_data_missing_with_default = copy.deepcopy(human_data_complete)
        human_data_missing_with_default['control1']['description'] = 'foo'
        
        c2outdesc = human_data_missing_with_default['control2']['description'] + render_constraints_markup(generated_test_controls[1]) 
        human_data_missing_with_default['control2']['description'] = c2outdesc
        
        self.assertEqual(
            human_data_missing_with_default,
            validate_controls(generated_test_controls,
                              human_data_missing_desc,
                              defaults=lookup
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
        test_output['cols'] = copy.deepcopy(DefaultMessageDocs['cols']) 
        test_output['cols']['args'] = []
        self.assertEqual(test_output,validate_messages(generated_data,test_input))
    
if __name__ == '__main__':
    unittest.main()
