import unittest
from ..SCDocWriter import *

from docutils.core import publish_parts

test_strings = {}

test_strings['footnote'] = [
"""\
A footnote [#f1]_ appearing inline 

.. [#f1] fn text!
""",
"A footnote FOOTNOTE::fn text!:: appearing inline" 
]

test_strings['formatted_footnote'] = [
"""\
A footnote [#f1]_ appearing inline 

.. [#f1] *fn* text!
""",
"A footnote FOOTNOTE::EMPHASIS::fn:: text!:: appearing inline" 
]

test_strings['literal_block'] = [
"""Here is code
::

    My code block is awesome
""", 
"""Here is code
CODE::
My code block is awesome
::"""
]

test_strings['bullet_list'] = [
"""\
Reasons my I'm beautiful:

* my smell 
* my ears 
* my toes
  
""", 
"""\
Reasons my I'm beautiful:
LIST::
## my smell
## my ears
## my toes
::"""
]

test_strings['def_list'] = [
r"""Reasons my I'm beautiful:

my smell 
    is fragant

my ears 
    these are also fragant

my toes
    are just pretty 
  
""", 
r"""Reasons my I'm beautiful:
DEFINITIONLIST::
## my smell
|| is fragant
## my ears
|| these are also fragant
## my toes
|| are just pretty
::"""
]

test_strings['number_list'] = [
r"""Reasons my I'm beautiful:

1. my smell 
2. my ears 
#. my toes
     
""", 
r"""Reasons my I'm beautiful:
NUMBEREDLIST::
## my smell
## my ears
## my toes
::"""
]

test_strings['table'] = [
"""\
.. table::
   :align: right

   +-----+-----+
   |  1  |  2  |
   +-----+-----+
   |  3  |  4  |
   +-----+-----+
""",
"""
TABLE::
## 1 || 2
## 3 || 4
::"""
]

class TestRst2SCDoc(unittest.TestCase):
                        
        def render(self,s):
            return publish_parts(source=s, writer=SCHelpWriter())['whole']
        
        def test_text(self):
            self.assertEqual("Lorem ipsum", self.render("Lorem ipsum"))

        def test_comment(self):
            str ="Testing Comment\n\n.. This Should Go"
            
            self.assertEqual("Testing Comment", self.render(str))
            
        # 
        # def test_docinfo_item(self, node, name):
        #     raise nodes.SkipNode
        # 
        def test_emphasis(self):            
            str = 'You *have* to be kidding'
            res = 'You EMPHASIS::have:: to be kidding'
            self.assertEqual(res,self.render(str))
                
        def test_strong(self):
            str = 'You **have** to be kidding'
            res = 'You STRONG::have:: to be kidding'
            self.assertEqual(res,self.render(str))
                
        def test_note(self):
            str = ".. note:: A Noteworthy thing"
            res = "NOTE::A Noteworthy thing::"
            self.assertEqual(res,self.render(str))
            
        def test_warning(self):
            str = ".. warning:: From history"
            res = "WARNING::From history::"
            self.assertEqual(res,self.render(str))
        
        def test_footnote(self):
            str = test_strings['footnote'][0]
            res = test_strings['footnote'][1]
            self.assertEqual(res,self.render(str))
            
        def test_formattedfootnote(self):
            str = test_strings['formatted_footnote'][0]
            res = test_strings['formatted_footnote'][1]
            self.assertEqual(res,self.render(str))

        def test_literal(self):
            token = 'my code is awesome'
            str = f'``{token}``'
            res = f'CODE::{token}::'
            self.assertEqual(res,self.render(str))

        def test_literal_block(self):
            str = test_strings['literal_block'][0]
            res = test_strings['literal_block'][1]
            self.assertEqual(res,self.render(str))
                
        def test_bullet_list(self):
            str = test_strings['bullet_list'][0]
            res = test_strings['bullet_list'][1].replace("\xa0", " ")
            self.assertEqual(res,self.render(str))

        def test_definition_list(self):
            str = test_strings['def_list'][0]
            res = test_strings['def_list'][1]
            self.assertEqual(res,self.render(str))
        
        def test_enumerated_list(self):
            str = test_strings['number_list'][0]
            res = test_strings['number_list'][1]
            self.assertEqual(res,self.render(str))        

        def test_table(self):
            str = test_strings['table'][0]
            res = test_strings['table'][1]
            self.assertEqual(res,self.render(str))        

    
if __name__ == '__main__':
    unittest.main()     
