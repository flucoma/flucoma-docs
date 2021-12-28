# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

import logging
from .common import PermissveSchema, not_yet_documented, RecordContext
from schema import Schema, And, Or, Optional, Use, SchemaError,Hook
from functools import partial, reduce
from ..defaults import DefaultControlDocs, DefaultMessageDocs
from ..logger import add_context

def render_constraints_markup(data, control):
    '''
    render reStructuredText markup for a control's constraints. 
    
    This is a hellscape of special cases 
    '''
    
    if not 'constraints' in control: return data
    
    constraints = control['constraints']
    
    upper = []
    lower = []
    snaps = {
        'powerTwo':'powers of two', 
        'odd': 'odd numbers'
    }
    
    special_invariants = {
        'fftFrame': '``(FFT Size / 2) + 1`` (see fft settings)',
        'maxFFTFrame': '(max FFFT Size / 2) + 1`` (see maxFFTSize)'
    } 
    
    resultStr = '\n**Constraints**\n\n'
    
    upperLimits = constraints.get('upper',[])
    lowerLimits = constraints.get('lower',[])
    
    upperLimits = [upperLimits] if not isinstance(upperLimits,list) else upperLimits
    lowerLimits = [lowerLimits] if not isinstance(lowerLimits,list) else lowerLimits
    
    upperStrs = [special_invariants.get(c,f'``{c}``') for c in upperLimits]
    lowerStrs = [special_invariants.get(c,f'``{c}``') for c in lowerLimits]
    
    if 'max' in constraints: upperStrs.append(str(constraints['max']))
    if 'min' in constraints: lowerStrs.append(str(constraints['min']))
    
    if len(lowerStrs) > 1:
        resultStr += f"* Minimum: MAX({', '.join(lowerStrs)})\n" 
    elif len(lowerStrs) == 1: 
        resultStr += f"* Minimum: {lowerStrs[0]}\n"

    if len(upperStrs) > 1:        
        resultStr += f"* Maximum: MIN({', '.join(upperStrs)})\n" 
    elif len(upperStrs) == 1: 
        resultStr += f"* Maximum: {upperStrs[0]}\n"

    if 'snap' in constraints: 
        resultStr += f"* Snaps to {snaps[constraints['snap']]} \n"
    
    if 'FreqAmpPair' in constraints:
        resultStr += '* Two amplitude + frequency pairs. Amplitudes are unbounded, frequencies in range 0-1\n'   
               
    if control['name'] == 'fftSettings':
        resultStr += "* FFTSize, if != -1, will snap to the next greatest power of two &gt; 4\n"
        if 'MaxFFT' in constraints:
            resultStr += '* The maximum FFT size is limited to the value of the ``maxFFTSize`` argument\n'
        resultStr += '* if FFT size != -1, then window size is clipped at FFT size\n\n'

    return data + resultStr + '\n'

class ConstraintSchema(Schema):
    """
    
    """
    def __init__(self, allData, *args, **kwargs):
        super(ConstraintSchema, self).__init__(*args, **kwargs)
        if not allData:
            raise TypeError(
                "Expected to pass all control data in (for constraint validity checking)")
        self.allData = allData

    def validate(self, data, _is_constraint_schema=True):
        data = super(ConstraintSchema, self).valid(
            data, _is_constraint_schema=False)
        return data


base_generated_controls_schema = {
    'name': str,
    'size': int,
    'type': str,
    'displayName': str,
    'fixed': bool,
    'default': Or(int, float, list, str, object, None),
    Optional('constraints'): Use(ConstraintSchema),
    Optional(object): object  # swallow up extras without complaint
}

"""
Do this in a class so we can check invariants like dealing with enum types 
"""
class GeneratedControlsSchema(Schema):

    def __init__(self, allData, *args, **kwargs):
        super(GeneratedControlsSchema, self).__init__(self,
                                                      base_generated_controls_schema,
                                                      *args,
                                                      **kwargs
                                                      )
        if not allData:
            raise TypeError(
                "Expected to pass all control data in (for constraint validity checking)")
        self.allData = allData

    def validate(self, data, _is_controls_schema=True):
        if _is_controls_schema:
            data = super(GeneratedControlsSchema, self).validate(
                data, _is_controls_schema=False)
            if(data['type'] == 'enum' and not 'values' in data):
                raise SchemaError(
                    f"Control {data['name']} has enum type but no values")

            if data['size'] > 1 and not isinstance(data['default'], list):
                raise SchemaError(
                    f"Control {data['name']} has size {data['size']} but only a scalar default")
            # @todo actually look at the number of elements in list defaults compared to size? (bit tricky because of slightly screwy way that list Controls are handled)
        return data

machine_message_schema = {
    'name': str,
    'args': [Optional(str)],
    'returns': str
}

def validate_generated_data(generated_data):
    return Schema([
        GeneratedControlsSchema(generated_data)
    ]).validate(generated_data)

def validate_controls(generated_control_data, human_control_data, **kwargs):
    """
    validate the 'parameters' block of human made doc against its canoncial, generated counterpart. If things are missing, try and find a default placeholder for that message, otherwise tag as undocumented. 
    
    We use the schema library for validation, whose natural inclination is to bail when stuff is missing. However, we just want to detect it and, if all else fails, tag it. So some mild acrobatics are invoked, with only petty crimes committed.  
    """
    lookup = kwargs.pop('defaults_lookup', DefaultControlDocs)
    logging.debug(f'validating controls...')    
    def hasContent(x):
        if not len(x):
            raise SchemaError
        return x

    def tryLookup(x, name, lookup):
        return lookup[name]
        
    def uncdocumented(x,scope): 
        """return the built in not documented tag string"""        
        logging.warning('not yet documented')#,extra={'context':scope})
        return not_yet_documented
    
    # deal with the aberation that is fftSettings (unified in generated docs, split out into win-hop-fft in human docs)
    if 'fftSettings' in [x['name'] for x in generated_control_data]:

        w = human_control_data.pop('windowSize')
        h = human_control_data.pop('hopSize') 
        f = human_control_data.pop('fftSize')

        human_control_data['fftSettings'] = {
            'win':w,'hop':h,'fft':f,
            'description':None
            #f"{w['description']}\n{h['description']}\n{f['description']}"
        }
        
    # first pass: anything missing from the structure gets put in, but with None as a value     
    s_first = PermissveSchema({
        Optional(d['name'], default={'description': None}): {
            Optional('description', default=None):object,
            Optional('enum'):object,
            Optional(object):object
        }
        for d in generated_control_data        
    }).validate(human_control_data)
            
    # second pass: for anything with None, we see if we have a stored default for this Control description, and if we don't then we use a 'not yet documented' shame banner
    s_second = PermissveSchema({
        d['name']: RecordContext({
            'description': And(
                Or(
                    Use(hasContent),
                    Use(partial(tryLookup, name=d['name'], lookup=lookup)),
                    Use(partial(uncdocumented,scope=d['name']))
                ), 
                Use(partial(render_constraints_markup,control=d))
            ),
            Optional('enum'):object,
            Optional(object):object
        }, 'control', d['name'])
        for d in generated_control_data 
    })
    
    result =  s_second.validate(s_first)
    # logging.getLogger().removeFilter(f)
    return result
