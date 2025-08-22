import unittest 

from docutils import nodes 
from docutils.core import publish_doctree 

from flucoma.doc.rst.docutils import parse_fieldlist

unnested = """\

:0: 0-stuff
:1: 1-stuff
:2: 2-stuff
"""

nested_content="""\
:0-0: nest0
:0-1: nest1
:0-2: nest2
:0-3:
    Let's put some more ``content`` **in** here

    * list0
    * list1
    * list2

:0-4: and relax\
"""

nested_nested_content="""\
Let's put some more ``content`` **in** here

* list0
* list1
* list2\
"""

nested1 = """\
:0:
    :0-0: nest0
    :0-1: nest1 
    :0-2: nest2
    :0-3: 
        Let's put some more ``content`` **in** here
        
        * list0 
        * list1 
        * list2 
    
    :0-4: and relax

:1: can we stop yet? 
"""

class TestFieldListParse(unittest.TestCase): 
    def test_unnested_parse(self):
        tree = publish_doctree(source=unnested)
        # print(tree.pformat())
        parsed = parse_fieldlist(tree)
        
        self.assertEqual(list(parsed.keys()),['0','1','2'])
        self.assertEqual(list(parsed.values()),['0-stuff','1-stuff','2-stuff'])
        
    def test_nested_parse_top(self):
        tree = publish_doctree(source=nested1)
        parsed = parse_fieldlist(tree)
        
        self.assertEqual(list(parsed.keys()),['0','1'])        
        self.assertEqual(list(parsed.values()),[nested_content,'can we stop yet?'])
        
    def test_nested_parse_inner(self):
        tree = publish_doctree(source=nested1)
        
        parent = tree.children[0]
        
        
        for i,n in enumerate(parent.children): #top level fields
            contains_subfields = n.next_node(nodes.field)
            if i == 0:
                self.assertTrue(contains_subfields)
            else:
                self.assertFalse(contains_subfields)
                
            if contains_subfields:
                subfields = parse_fieldlist(n)  
                self.assertEqual(list(subfields.keys()),['0-0','0-1','0-2','0-3','0-4'])     
                self.assertEqual(list(subfields.values()),[
                    'nest0','nest1','nest2',nested_nested_content,'and relax'
                ])
