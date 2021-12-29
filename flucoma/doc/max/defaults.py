


defaults = {
    'messages': {
        'dump':{
            'description':'Dump the state of this object from the dump outlet as a <o>dict</o>.',
            'args':[]
        }, 
        'load':{
            'description':'Replace the internal state of the object from a <o>dict</o>. The message should take the form <code>load dictionary &lt;dictid&gt;</code>' ,       
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
            'description': 'Replace the internal state of the object from a JSON file on disk. With no argument, a file dialog will appear to choose the file.',
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
            'description':'Save the internal state of the object to a JSON file on disk. With no argument, a file dialog will appear to choose the file.',
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
