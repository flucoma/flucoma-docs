# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

def warningDoc():
    return {
        "displayName" : "Warnings",
        "constraints": {
            "min": 0,
            "max": 1
        } ,
        "default": 0,
        "type": "long",
        "size": 1,
        "fixed": False,
        "description" : "Enable warnings to be issued whenever a parameter value is constrained (e.g. clipped)"
    }
    
def blockingDoc(): 
    return {
        "displayName" : "Blocking Mode",
        "default": 1,
        "fixed": False,
        "size": 1,
        "type": "enum",
        "values": [
            "Non-Blocking",
            "Blocking (Low Priority)",
            "Blocking (High Priority)"
        ],
        "enum": {
            "Non-Blocking": "Processing runs in a worker thread",
            "Blocking (Low Priority)" : "Processing runs in the main application thread",
            "Blocking (High Priority)" : "(Max only) Processing runs in the scheduler thread"
        },
        "description" : "Set the threading mode for the object"
    }
        
def queueDoc():
    return {
        "displayName" : "Non-Blocking Queue Flag",
        "default": 0,
        "fixed": False,
        "size": 1,
        "type": "long",
        "description" : "In non-blocking mode enable jobs to be queued up if successive bangs are sent whilst the object is busy. With the queue disabled, successive bangs will produce a warning. When enabled, the object will processing successively, against the state of its parameters when each bang was sent"
    }
    
def fftDoc(): 
    return  'FFT settings consist of three numbers representing the window size, hop size and FFT size in samples:\n\nThe hop size and fft size can both be set to -1 (and are by default), with slightly different meanings:\n   \n* For the hop size, -1 = ``windowSize/2``\n* For the FFT size, -1 = ``windowSize`` snapped to the nearest equal / greater power of 2 (e.g. ``windowSize 1024`` => ``fftSize 1024``, but ``windowsSize 1000`` also => ``fftSize 1024``)\n'    

def colsDoc():
    return {
        'description': 'The number of columns (dimensions) in this model or dataset / labeset', 
        'args':[],                        
    }

def sizeDoc():
    return {
        'description': 'The number of data points (entries / observations) in this model or dataset / labeset', 
        'args':[],                        
    }
    
def clearDoc(): 
    return {
        'description': 'Resets the internal state of the model', 
        'args':[],                        
    }

DefaultControlDocs = {
    'warnings': warningDoc(), 
    'blocking': blockingDoc(), 
    'queue': queueDoc(),
    'fftSettings':fftDoc()
}

DefaultMessageDocs = {
    'cols' : colsDoc(),
    'size' : sizeDoc(), 
    'clear': clearDoc()
}
