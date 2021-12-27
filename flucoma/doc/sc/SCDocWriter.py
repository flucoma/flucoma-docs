"""Simple schelp writer from RST blocks. Not designed to cope with whole documents yet (for which I use jinja). Largely cribbed from https://github.com/cgwrench/rst2md/blob/master/markdown.py"""

import docutils
from docutils import frontend, nodes, writers, languages
from collections.abc import Iterable

class SCHelpWriter(writers.Writer):
    
    supported = ('schelp',)
    
    output = None
    
    def __init__(self):
        writers.Writer.__init__(self)
        self.translator_class = SCHelpTranslator
        
    def translate(self):
        visitor = self.translator_class(self.document)
        self.document.walkabout(visitor)
        self.output = visitor.astext()

class SCHelpTranslator(nodes.NodeVisitor):
    def __init__(self, document):    
        nodes.NodeVisitor.__init__(self, document)
        self.settings = settings = document.settings
        lcode = settings.language_code
        self.language = languages.get_language(lcode, document.reporter)

        self.head = []
        self.body = []
        self.foot = []
        self.foonote_start = -1;  
        self.section_level = 0
        
        self.colindex = 0
        
        self._docinfo = {
        'title' : '',
        'subtitle' : '',
        'author' : [],
        'date' : '',
        'copyright' : '',
        'version' : '',
        }
        
        # SCHELP syntax things that I'm bothered about here
        self.defs = {
            'emphasis': ('EMPHASIS::', '::'),  
            'strong' : ('STRONG::', '::'),  
            'note': ('NOTE::','::'), 
            'warning' : ('WARNING::','::'), 
            'footnote' : ('FOOTNOTE::','::'), 
            'literal' : ('CODE::','::'), 
            'literal_block' : ('\nCODE::\n','::'),
            'bullet_list' : ('\nLIST::\n','::'), 
            'definition_list': ('\nDEFINITIONLIST::\n','::'), 
            'enumerated_list': ('\nNUMBEREDLIST::\n','::'), 
            'list_item': ('## ',''), 
            'term': ('|| ',''),
            'table': ('\nTABLE::\n','::')
        }        

    def astext(self):
        """Return the final formatted document as a string."""
        return ''.join(self.head + self.body + self.foot)

    def deunicode(self, text):
        text = text.replace(u'\xa0', '\\ ')
        text = text.replace(u'\u2020', '\\(dg')
        return text

    def ensure_eol(self):
        """Ensure the last line in body is terminated by new line."""
        if self.body and self.body[-1][-1] != '\n':
            self.body.append('\n')


    def visit_Text(self, node):
        text = node.astext()
        self.body.append(text)

    def depart_Text(self, node):
        pass

    def visit_label(self, node):
        raise nodes.SkipNode

    def depart_label(self, node):
        pass

    def visit_comment(self, node):
        raise nodes.SkipNode
        
    def visit_docinfo_item(self, node, name):
        raise nodes.SkipNode

    def visit_document(self, node):
        pass

    def depart_document(self, node):
        pass    
    
    def visit_body(self, node):
        pass

    def depart_body(self, node):
        pass       
        
    def visit_emphasis(self, node):
        self.body.append(self.defs['emphasis'][0])

    def depart_emphasis(self, node):
        self.body.append(self.defs['emphasis'][1])    
    
    def visit_strong(self, node):
        self.body.append(self.defs['strong'][0])

    def depart_strong(self, node):
        self.body.append(self.defs['strong'][1]) 

    def visit_note(self,node):
        self.body.append(self.defs['note'][0])

    def depart_note(self,node):
    	self.body.append(self.defs['note'][1])

    def visit_warning(self,node):
    	self.body.append(self.defs['warning'][0])

    def depart_warning(self,node):
    	self.body.append(self.defs['warning'][1])
    
    """
    Footnotes, eh? RST helpfully keeps the footnote references and footnote definitions separate, which is great for most circumstances but not SCDoc, because footnotes are inline. So we have to do a dance 
    * when we encounter a footnote reference in the RST, put a special string in the list (this could be more robust, but let's see)
    * when we encounter a footnote (presumably later), keep appending things to the body (list of strings to be output), but mark where we are. We need to keep walking in case the footnote text has more formatting. 
    * when we depart the footnote, splice the body list at the point where the marker is with the new text 
    
    This is *horrible*, sorry. And it won't work for nested footnotes (are they even a thing in SCDoc?)
    
    """    
    def visit_footnote(self,node):
        
        #make a mark 
        self.footnote_start = len(self.body); 
        
        # raise nodes.SkipNode

    def depart_footnote(self,node):
        
        newBody = self.body[:self.footnote_start]
        footnoteItems = self.body[self.footnote_start:]
            
        # now, we have a problem in that rst will let us multiply refer to the same footnote, but SCDoc doesn't really have that concept. Better, I think to produce multiple footnotes than barf? 
        
        #find all the special strings
        token = f"footnote-ref-{node['ids'][0]}"
        indices = [i for i,x in enumerate(newBody) if x==token]        
        if not len(indices):
             return
        #plonk in sublists at key points        

        for i in indices:
            newBody[i] = footnoteItems

        # now we have an irregular nested list to flatten (tried doing this with slice insertion but couldn't make it work?)
        def flatten(l):
            for x in l: 
                if isinstance(x, Iterable) and not isinstance(x,(str,bytes)):
                    yield from flatten(x)
                else:
                    yield x
        
        newBody = list(flatten(newBody))
        self.body = newBody
        self.footnote_start = -1
        
    def visit_footnote_reference(self, node):
        self.body.append(self.defs['footnote'][0])
        self.body.append(f"footnote-ref-{node['refid']}") 
        self.body.append(self.defs['footnote'][1]) 
        raise nodes.SkipNode      

    def depart_footnote_reference(self, node):        
        pass
        
    def visit_literal(self,node):
    	self.body.append(self.defs['literal'][0])

    def depart_literal(self,node):
    	self.body.append(self.defs['literal'][1])

    def visit_literal_block(self,node):
    	self.body.append(self.defs['literal_block'][0])

    def depart_literal_block(self,node):
    	self.body.append(f"\n{self.defs['literal_block'][1]}")

    def visit_bullet_list(self,node):
    	self.body.append(self.defs['bullet_list'][0])

    def depart_bullet_list(self,node):
    	self.body.append(self.defs['bullet_list'][1])

    def visit_definition_list(self,node):
    	self.body.append(self.defs['definition_list'][0])

    def depart_definition_list(self,node):
    	self.body.append(self.defs['definition_list'][1])
        
    def visit_definition_list_item(self,node):     
        pass

    def depart_definition_list_item(self,node):
        pass
    
    def visit_definition(self,node):       
        self.body.append('|| ')

    def depart_definition(self,node):
        self.body.append('\n')
        
    def visit_term(self,node):         
        self.body.append(f"{self.defs['list_item'][0]}")

    def depart_term(self,node):
        self.body.append('\n')

    def visit_enumerated_list(self,node):
    	self.body.append(self.defs['enumerated_list'][0])

    def depart_enumerated_list(self,node):
    	self.body.append(self.defs['enumerated_list'][1])

    def visit_list_item(self,node):
        self.body.append(self.defs['list_item'][0])

    def depart_list_item(self,node):
    	self.body.append(f"{self.defs['list_item'][1]}\n")

    def visit_table(self,node):
    	self.body.append(self.defs['table'][0])

    def depart_table(self,node):
    	self.body.append(self.defs['table'][1])

    def visit_tgroup(self,node):
    	pass

    def depart_tgroup(self,node):
    	pass

    def visit_tbody(self,node):
        # print(node)
    	pass

    def depart_tbody(self,node):
    	pass
    
    # no nested tables just yet (does SC cope with them??)
    def visit_row(self,node):
        self.colindex = 0  
        # self.body.append('\n')
        # self.body.append(self.defs['list_item'][0])
        
    def depart_row(self,node):
        # pass
    	self.body.append(f"{self.defs['list_item'][1]}\n")
    
    def visit_entry(self,node):
        if self.colindex == 0:
            self.body.append(f"{self.defs['list_item'][0]}")
        else: 
            self.body.append(f" {self.defs['term'][0]}")
        self.colindex += 1
        # print(node)    	

    def depart_entry(self,node):
    	pass
        
    def visit_colspec(self,node):
        pass  	

    def depart_colspec(self,node):
    	pass    
        
    def visit_paragraph(self,node):
        # self.ensure_eol()
        # self.body.append('\n')
        pass
    
    def depart_paragraph(self, node):
        # self.body.append('\n')
        pass
        
        
rst_elements = ('abbreviation', 'acronym', 'address', 'admonition',
    'attention', 'attribution', 'author', 'authors', 'block_quote', 
    'bullet_list', 'caption', 'caution', 'citation', 'citation_reference', 
    'classifier', 'colspec', 'comment', 'compound', 'contact', 'container', 
    'copyright', 'danger', 'date', 'decoration', 'definition',
    'definition_list', 'definition_list_item', 'description', 'docinfo', 
    'doctest_block', 'document', 'emphasis', 'entry', 'enumerated_list', 
    'error', 'field', 'field_body', 'field_list', 'field_name', 'figure', 
    'footer', 'footnote', 'footnote_reference', 'generated', 'header', 
    'hint', 'image', 'important', 'inline', 'label', 'legend', 'line', 
    'line_block', 'list_item', 'literal', 'literal_block', 'math', 
    'math_block', 'note', 'option' ,'option_argument', 'option_group', 
    'option_list', 'option_list_item', 'option_string', 'organization', 
    'paragraph', 'pending', 'problematic', 'raw', 'reference', 'revision', 
    'row', 'rubric', 'section', 'sidebar', 'status', 'strong', 'subscript', 
    'substitution_definition', 'substitution_reference', 'subtitle', 
    'superscript', 'system_message', 'table', 'target', 'tbody,' 'term', 'text'
    'tgroup', 'thead', 'tip', 'title', 'title_reference', 'topic', 
    'transition','version','warning')

_warned = set()
        
def visit_unsupported(self, node):
    node_type = node.__class__.__name__
    if node_type not in _warned:
        self.document.reporter.warning('The ' + node_type + \
            ' element is not supported.')
        _warned.add(node_type)
    raise nodes.SkipNode
    

for element in rst_elements:
    if not hasattr(SCHelpTranslator, 'visit_' + element):
        setattr(SCHelpTranslator, 'visit_' + element , visit_unsupported)
     
