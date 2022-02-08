import unittest
import re
from flucoma.doc.rst.docutils import register_custom_directives
from docutils.core import publish_string

only_in_sc = 'only in sc!!'
only_in_max = 'only in max!!'
in_both = 'this should be in Max or SC'
in_nothing = 'in nothing'
test_string = f""" This should be

.. only_in:: sc

   {only_in_sc}

.. only_in:: max

   {only_in_max}

.. only_in:: max sc

   {in_both}

.. only_in:: slartybartfarst

   {in_nothing}

"""

class TestOnlyIn(unittest.TestCase):

    def test_sc_only(self):
        register_custom_directives()
        settings = {'flucoma-host': 'sc'}
        res = str(publish_string(source=test_string,
                  settings_overrides=settings))

        self.assertIsNotNone(re.search(only_in_sc, res))
        self.assertIsNotNone(re.search(in_both, res))

        self.assertIsNone(re.search(only_in_max, res))
        self.assertIsNone(re.search(in_nothing, res))

        settings = {'flucoma-host': 'max'}
        res = str(publish_string(source=test_string,
                  settings_overrides=settings))

        self.assertIsNotNone(re.search(only_in_max, res))
        self.assertIsNotNone(re.search(in_both, res))

        self.assertIsNone(re.search(only_in_sc, res))
        self.assertIsNone(re.search(in_nothing, res))
