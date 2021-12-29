

defaults = {
    'messages': {
        'dump':{
            'description':'Dump the state of this object from the dump outlet as a `<Classes/Dictionary>`__', 
            'args':[]
        }, 
        'load':{
            'description':'Replace the internal state of the object from a `<Classes/Dictionary>`__.',  
            'args':[
                {
                    'name':'data',
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
                    'name':'path',
                    'optional': 1,
                    'type':'symbol',
                    'description':'Path of the file to load from'            
                }
            ] 
        },
        'write':{
            'description':'Save the internal state of the object to a JSON file on disk.',
            'args': [
                {
                    'name':'path',
                    'optional': 1,
                    'type':'symbol',
                    'description':'Path of the file to load from'            
                }
            ]         
        }
    }
}
