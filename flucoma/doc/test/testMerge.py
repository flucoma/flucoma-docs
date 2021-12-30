# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import unittest
import copy

from .data import generated_test_controls, generated_test_messages, human_data_complete, human_message_data_complete
from flucoma.doc.merge import merge_object 

class TestMergeObject(unittest.TestCase):
    
    def test_merge(self):
        
        gen_obj = { 
            'name':'TestObj',
            'parameters':copy.deepcopy(generated_test_controls),
            'messages':copy.deepcopy(generated_test_messages)            
        }
        
        human_obj = {
            'parameters':human_data_complete, 
            'messages':human_message_data_complete
        }
        
        merged = merge_object(gen_obj,human_obj)
        from pprint import pprint
        
        pprint(merged)
        
        self.assertEqual(len(merged['parameters']),len(gen_obj['parameters']))
        self.assertEqual(len(merged['messages']),len(gen_obj['messages']))
        
        for i,p in enumerate(merged['parameters']):
            self.assertEqual(
                p['name'],
                gen_obj['parameters'][i]['name']
            )
            self.assertEqual(
                p['displayName'],
                gen_obj['parameters'][i]['displayName']
            )
            self.assertEqual(
                p['type'],
                gen_obj['parameters'][i]['type']
            )
            self.assertEqual(
                p['default'],
                gen_obj['parameters'][i]['default']
            )
            self.assertEqual(
                p['size'],
                gen_obj['parameters'][i]['size']
            )
            self.assertEqual(
                p['fixed'],
                gen_obj['parameters'][i]['fixed']
            )
            self.assertEqual(
                p['constraints'],
                gen_obj['parameters'][i]['constraints']
            )
            self.assertEqual(
                p['description'],
                human_obj['parameters'][p['name']]['description']
            )
        
        for i,m in enumerate(merged['messages']):
            self.assertEqual(
                m['name'],
                gen_obj['messages'][i]['name']
            )
            self.assertEqual(
                m['description'],
                human_obj['messages'][m['name']]['description']
            )   
            self.assertEqual(
                m['returns'],
                gen_obj['messages'][i]['returns']
            )   
            for j,a in enumerate(m['args']):
                self.assertEqual(
                    a['name'],
                    human_obj['messages'][m['name']]['args'][j]['name']
                )
                self.assertEqual(
                    a['description'],
                    human_obj['messages'][m['name']]['args'][j]['description']
                )
                self.assertEqual(
                    a['type'],
                    gen_obj['messages'][i]['args'][j]
                )

            # self.assertEqual(
            #     p['displayName'],
            #     gen_obj['parameters'][i]['displayName']
            # )
            # self.assertEqual(
            #     p['type'],
            #     gen_obj['parameters'][i]['type']
            # )
            # self.assertEqual(
            #     p['default'],
            #     gen_obj['parameters'][i]['default']
            # )
            # self.assertEqual(
            #     p['size'],
            #     gen_obj['parameters'][i]['size']
            # )
            # self.assertEqual(
            #     p['fixed'],
            #     gen_obj['parameters'][i]['fixed']
            # )
            # self.assertEqual(
            #     p['constraints'],
            #     gen_obj['parameters'][i]['constraints']
            # )
            # self.assertEqual(
            #     p['description'],
            #     human_obj['parameters'][p['name']]['description']
            # )    
        
        
            

if __name__ == '__main__':
    unittest.main() 
