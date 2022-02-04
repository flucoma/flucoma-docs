import textwrap
from flucoma.doc.rst.common import LogDocutilsMessages
from pprint import pprint, pformat
import docutils.nodes
from docutils.parsers import rst
from docutils.parsers.rst import directives
import docutils.utils
import docutils.frontend
from docutils import nodes
from docutils.parsers.rst.states import Inliner
from docutils.utils import Reporter
import copy
import re
import logging

"""
Parse the structure of a FluCoMa object reference from reStructuredText. We use a structured rst represntation of field lists to represent the various parts of an object's reference.

@todo document this structure 

Currently only the high-level elements of the rST are parsed at this stage: we don't interpret the inline formating of block elements until the output reference files are rendered. Doing it this way means we have been able to have a managed transition from YAML based docs to rST whilst being able to test and verify automatic conversion, and without having to touch an as yet unknown quantity of code in flucoma.doc

Doing it this way turns out to require a certain number of code crimes, because there are things that seem like they'd be inline elements until you think about it. Most particularly, without some special care, rST tables got completely nuked when just using node.astext() to recover content. 

What's especially complex is that the fields for :control:s and :message:s may have sub-field-lists for enum values or arguments respectively, as well as arbitary other content documenting the entity. The field lists need to be parsed and translated for the verification stage of the document rendering, but the other elements' source text needs to be recovered raw and parsed later. sad face 

The way out of this will be to 
* do all the parsing up front 
* wrap the node representations of control enums and arg lists in such a way as to make the schema validation work 
* work out if we can do the writing stage straight from the parsed nodes, and if so whether this has to be the whole document, or whether we can go chunk by chunk as currently 

"""

class NoInliner(Inliner):
    """
    Stops the rst parser doing parsing of the inline elements, which we do later
    """
    def init_customizations(self, settings):
        pass

    def parse(self, text, lineno, memo, parent):
        
        node = nodes.Text(text)

        return [node], []

class MessageArgPartsVistor(nodes.SparseNodeVisitor):
    """
    visitor to extract message argument names and descriptions into a list of dict
    """
    def __init__(self, document):
        nodes.SparseNodeVisitor.__init__(self,document)
        self.args = []
        self.current_arg = None
        self.pattern = re.compile("arg\s+(.+)")
        self.line = 0 
        self.last_node = None

    def visit_field(self, node):
        self.line = node.line
        self.current_arg = {'name':None,'description':None}
    
    def depart_field(self,node): 
        if(self.current_arg):
            self.args.append(self.current_arg)

    def visit_field_name(self, node):
        n = self.pattern.match(node.astext())
        # print("matching", node.astext(), n.groups(1)[0])
        if n:
            self.current_arg["name"] = n.groups(1)[0]
        raise nodes.SkipNode

    def visit_field_body(self, node):
        self.current_arg["description"] = node.astext()
        self.last_node = node
        raise nodes.SkipNode
 
pattern = re.compile("(.+)\s+(.+)")
    
class LineMarkVisitor(nodes.GenericNodeVisitor):
    """
    visitor to record the line numbers of each child of a node, for later extraction
    """
    def __init__(self,document):
        nodes.GenericNodeVisitor.__init__(self,document)    
        self.lines = set()

    def default_visit(self, node):        
        if(node.line): self.lines.add(node.line)

def recover_raw_text(node,lines): 
    """
    given a block of raw lines and a node, walk the node's children and pull out the corresponding lines, making an effort to ensure that block elements are still properly separated by a blank line 
    """
    visitor = LineMarkVisitor(node.document)
    node.walk(visitor)
    index = list(sorted(visitor.lines))
    raw_lines = [lines[i - 1] for i in index]    

    # try and preserve proper separation between blocks
    # if the raw line following each content line (except the last) is blank, add a \n
    for i,l in enumerate(raw_lines[:-1]): 
        try: 
            if lines[index[i]].strip() == '': #blank line  
                raw_lines[i] += '\n'
        except IndexError:
            pass
    return raw_lines

def control(name,node,obj,lines):
    """
    parse a control field, separating out any possible :enum: block and keeping the descrpition un-parsed
    """
    obj['parameters'][name] = {'description':None}    
    o = obj['parameters'][name]
    
    #control might have enum options        
    idx = node.first_child_matching_class(nodes.field_list)
    if idx is not None:
        items = node.children[idx].findall(nodes.field)
        for f in items:
            if pattern.match(f.astext().strip()).group(1) == 'enum':
                name = list(f.findall(nodes.field_name))[0].astext().strip()
                value = list(f.findall(nodes.field_body))[0].rawsource.strip()
                o['enum'] = {}
                o['enum'][name] = value
                node.children.remove(node.children[idx])  
        
    o['description'] = (
        # 
        ''.join(recover_raw_text(node,lines))
        if len(node.children) 
        else None
    )

    return obj

def message(name,node,obj,lines):
    """
    parse a message field, separating out any possible :args: blocks and keeping the descrpition un-parsed
    """
    obj['messages'][name] = {'description':None }    
    o = obj['messages'][name]
    #message might have args         
    idx = node.first_child_matching_class(nodes.field_list)
    if idx is not None:
        visitor = MessageArgPartsVistor(node.document)
        node.children[idx].walkabout(visitor)
        o['args'] = visitor.args
        node.children.remove(node.children[idx])
    

    o['description'] = (
        ''.join(recover_raw_text(node,lines))                
        if len(node.children) 
        else None
    )
    return obj

def parse(content):
    
    lines = content.splitlines(keepends=True)
    
    parser = rst.Parser(inliner=NoInliner())
    components = (rst.Parser,)
    
    settings = docutils.frontend.OptionParser(
        components=components,         
    ).get_default_values()
    
    document = docutils.utils.new_document("<rst-doc>", settings=settings)
    
    # Grab docutils error messages for ourselves so we can provide useful context
    def log_badness(message):
        logging.warning(f"{nodes.Element.astext(message)}\n\t{lines[message['line']-1]}")
        
    document.reporter.attach_observer(log_badness)
    document.reporter.stream = None
    
    parser.parse(content, document)
        
    def find_children(node,cls):
        return node.children[0].findall(cls,descend=False,siblings=True)
    
    fieldlists = find_children(document,nodes.field_list) 
    
    object = {'parameters':{},'messages':{}}
    for fl in fieldlists:        
        for f in find_children(fl,nodes.field):         
            name = list(find_children(f,nodes.field_name))[0]
            content = list(find_children(f,nodes.field_body))[0]            
            parts = pattern.match(name.astext().strip())
            if parts:
                globals()[parts.group(1)](parts.group(2),content, object,lines)    
            else:                 
                start = f.line
                end =f.next_node(descend=False,ascend=True,siblings=True).line
                if end - start > 1:
                    
                    body = content.rawsource
                else: 
                    body = content.astext()
                object[name.astext().strip()] = body.strip()

    return object
            
