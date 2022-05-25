def derive_learn_link(object_name):
    url_map = {
        'bufampfeature' : 'ampfeature',
        'bufnoveltyfeature' : 'noveltyfeature',
        'bufonsetfeature' : 'onsetfeature',
        'bufspectralshape' : 'spectralshape',
        'bufchroma' : 'chroma',
        'bufloudness' : 'loudness',
        'bufmelbands' : 'melbands',
        'bufmfcc' : 'mfcc',
        'bufpitch' : 'pitch',
        'bufhpss' : 'hpss',
        'bufsines' : 'sines',
        'buftransients' : 'transients',
        'bufampgate' : 'ampgate',
        'bufampslice' : 'ampslice',
        'bufnoveltyslice' : 'noveltyslice',
        'bufonsetslice' : 'onsetslice',
        'buftransientslice' : 'transientslice',
        'bufaudiotransport' : 'audiotransport'
    }
    return url_map.get(object_name.lower()) or object_name.lower()