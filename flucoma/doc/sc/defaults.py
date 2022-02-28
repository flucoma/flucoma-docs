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
            'description':'Dump the state of this object as a `<Classes/Dictionary>`__, which will be passed to the action function provided. This object must first be ``fit``ted before ``dump`` can be called.',
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
            'description':'Save the internal state of the object to a JSON file on disk. This object must first be ``fit``ted before ``write`` can be called.',
            'args': [
                {
                    'name':'filename',
                    'optional': 1,
                    'type':'symbol',
                    'description':'Path of the file to load from'
                }
            ]
        }
    },
    'controls': {
      "harmThresh": {
        "harmThreshFreq1": {
          "description": "In modes 1 and 2, the frequency of the low part of the threshold for the harmonic filter (0-1)"
        },
        "harmThreshAmp1": {
          "description": "In modes 1 and 2, the threshold of the low part for the harmonic filter. That threshold applies to all frequencies up to harmThreshFreq1: how much more powerful (in dB) the harmonic median filter needs to be than the percussive median filter for this bin to be counted as harmonic."
        },
        "harmThreshFreq2": {
          "description": "In modes 1 and 2, the frequency of the hight part of the threshold for the harmonic filter. (0-1)"
        },
        "harmThreshAmp2": {
          "description": "In modes 1 and 2, the threshold of the high part for the harmonic filter. That threshold applies to all frequencies above harmThreshFreq2. The threshold between harmThreshFreq1 and harmThreshFreq2 is interpolated between harmThreshAmp1 and harmThreshAmp2. How much more powerful (in dB) the harmonic median filter needs to be than the percussive median filter for this bin to be counted as harmonic."
        }
      },
      "percThresh": {
        "percThreshFreq1": {
          "description": "In mode 2, the frequency of the low part of the threshold for the percussive filter. (0-1)"
        },
        "percThreshAmp1": {
          "description": "In mode 2, the threshold of the low part for the percussive filter. That threshold applies to all frequencies up to percThreshFreq1. How much more powerful (in dB) the percussive median filter needs to be than the harmonic median filter for this bin to be counted as percussive."
        },
        "percThreshFreq2": {
          "description": "In mode 2, the frequency of the hight part of the threshold for the percussive filter. (0-1)"
        },
        "percThreshAmp2": {
          "description": "In mode 2, the threshold of the high part for the percussive filter. That threshold applies to all frequencies above percThreshFreq2. The threshold between percThreshFreq1 and percThreshFreq2 is interpolated between percThreshAmp1 and percThreshAmp2. How much more powerful (in dB) the percussive median filter needs to be than the harmonic median filter for this bin to be counted as percussive."
        }
      }
    }
}
