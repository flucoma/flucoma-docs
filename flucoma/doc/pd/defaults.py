


defaults = {
    'messages': {
        # No dump and load in PD 
        'dump':{
            'description':None,
            'args':[]
        }, 
        'load':{
            'description':None,
            'args':[]
        }, 
        'read':{
            'description': 'Replace the internal state of the object from a JSON file on disk.',
            'args': [
                {
                    'name':'path',
                    'optional': 0,
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
                    'optional': 0,
                    'type':'symbol',
                    'description':'Path of the file to load from'            
                }
            ]         
        }
    }
}
