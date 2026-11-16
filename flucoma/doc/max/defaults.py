# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).


defaults = {
    'messages': {
        'dump':{
            'description':'Dump the state of this object from the dump outlet as a :object-link:`dict`. This object must first be fitted before dump can be called.',
            'args':[]
        }, 
        'load':{
            'description':'Replace the internal state of the object from a :object-link:`dict`. The message should take the form ``load dictionary <dictid>``',       
            'args':[
                {
                    'name':'dictid',
                    'optional': 0,
                    'type':'dictionary',
                    'description':'Name of the :object-link:`dict` to load from'
                }
            ]
        }, 
        'read':{
            'description': 'Replace the internal state of the object from a JSON file on disk. With no argument, a file dialog will appear to choose the file. It is always executed at the lowest priority on the main thread, using ``deferlow`` internally.',
            'args': [
                {
                    'name':'path',
                    'optional': 1,
                    'type':'symbol',
                    'description':'Path of the file to load from'            
                }
            ] 
        },
        'write':{
            'description':'Save the internal state of the object to a JSON file on disk. With no argument, a file dialog will appear to choose the file. It is always executed at the lowest priority on the main thread, using ``deferlow`` internally. This object must first be fitted before write can be called.',
            'args': [
                {
                    'name':'path',
                    'optional': 1,
                    'type':'symbol',
                    'description':'Path of the file to save to'            
                }
            ]         
        }
    }
}
