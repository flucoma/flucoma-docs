# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from flucoma.doc.validate.common import not_yet_documented

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
