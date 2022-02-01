# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

defaults = {
    'messages': {
        'dump':{
            'description':'Dump the state of this object as a `<Classes/Dictionary>`__, which will be passed to the action function provided. This object must first be code::.fit:: before code::.dump:: can be called.',
            'args':[]
        },
        'load':{
            'description':'Replace the internal state of the object from a `<Classes/Dictionary>`__.',
            'args':[
                {
                    'name':'dict',
                    'optional': 0,
                    'type':'dictionary',
                    'description':''
                }
            ]
        },
        'read':{
            'description': 'Replace the internal state of the object from a JSON file on disk. ',
            'args': [
                {
                    'name':'filename',
                    'optional': 1,
                    'type':'symbol',
                    'description':'Path of the file to load from'
                }
            ]
        },
        'write':{
            'description':'Save the internal state of the object to a JSON file on disk. This object must first be code::.fit:: before code::.write:: can be called.',
            'args': [
                {
                    'name':'filename',
                    'optional': 1,
                    'type':'symbol',
                    'description':'Path of the file to load from'
                }
            ]
        }
    }
}
