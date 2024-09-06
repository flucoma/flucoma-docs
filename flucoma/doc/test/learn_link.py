import unittest
from pathlib import Path
from flucoma.doc.learn import derive_learn_link

# A dictionary of client names and what they _should_ become after deriving the learn link
url_map = {
    'BufAmpFeature' : 'ampfeature',
    'BufNoveltyFeature' : 'noveltyfeature',
    'BufOnsetFeature' : 'onsetfeature',
    'BufSpectralShape' : 'spectralshape',
    'BufChroma' : 'chroma',
    'BufLoudness' : 'loudness',
    'BufMelbands' : 'melbands',
    'BufMFCC' : 'mfcc',
    'BufPitch' : 'pitch',
    'BufHPSS' : 'hpss',
    'BufSines' : 'sines',
    'BufTransients' : 'transients',
    'BufAmpGate' : 'ampgate',
    'BufAmpSlice' : 'ampslice',
    'BufNoveltySlice' : 'noveltyslice',
    'BufOnsetSlice' : 'onsetslice',
    'BufTransientSlice' : 'transientslice',
    'BufAudioTransport' : 'audiotransport',
    'BufCompose' : 'bufcompose',
    'BufNMF' : 'bufnmf',
    'BufSTFT' : 'bufstft',
    'BufScale' : 'bufscale',
    'BufFlatten' : 'bufflatten'
}

class TestLinkDerivation(unittest.TestCase):
    def test_link_derives_correctly(self):
        for k, v in url_map.items():
            self.assertEqual(derive_learn_link(k), v)