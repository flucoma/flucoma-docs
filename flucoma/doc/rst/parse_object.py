import textwrap
from pprint import pprint, pformat
import docutils.nodes
from docutils.parsers import rst
from docutils.parsers.rst import directives
import docutils.utils
import docutils.frontend
from docutils import nodes
from docutils.parsers.rst.states import Inliner
import copy
import re


class NoInliner(Inliner):
    def init_customizations(self, settings):
        pass

    def parse(self, text, lineno, memo, parent):

        node = nodes.Text(text)

        return [node], []


# class MessageNode(nodes.Element):
# 
# 
#     name = None
#     description = None
#     args = None
# 
# 
# class ControlNode(nodes.Element):
#     name = None
#     description = None
#     enum = None


class MessageArgPartsVistor(nodes.SparseNodeVisitor):

    def __init__(self, document):
        nodes.SparseNodeVisitor.__init__(self,document)
        self.args = []
        self.current_arg = None
        self.pattern = re.compile("arg\s+(.+)")

    def visit_field(self, node):
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
        raise nodes.SkipNode


# class Message(rst.Directive):
# 
#     has_content = True
#     required_arguments = 1
# 
#     def run(self):
#         node = MessageNode()
#         node.name = self.arguments[0] if len(self.arguments) else None
# 
#         self.state.nested_parse(self.content, self.content_offset, node)
# 
#         idx = node.first_child_matching_class(nodes.field_list)
#         if idx is not None:
#             visitor = MessageArgPartsVistor(self.state.document)
#             node.children[idx].walkabout(visitor)
#             node.args = visitor.args
#             node.children.remove(node.children[idx])
# 
#         node.description = node.astext()
#         # node.children = []
#         return [node]
# 
# 
# directives.register_directive("message", Message)


# class InnerEnumVistor(nodes.SparseNodeVisitor):
#     def __init__(self, document):
#         nodes.SparseNodeVisitor.__init__(self,document)
#         self.object = {}
#         self.current_key = None 
# 
#     def visit_field_name(self,node):
#         self.current_key = node.astext().strip()
#         raise nodes.SkipNode
# 
#     def visit_field_body(self, node):
#         if self.current_key: 
#             self.object[self.current_key] = node.astext().strip()
#         self.current_key = None
#         raise nodes.SkipNode
# 
#     def depart_field
        

# class ControlEnumVistor(nodes.SparseNodeVisitor):
#     def __init__(self, document):
#         nodes.SparseNodeVisitor.__init__(self,document)
#         self.enum = None   
#         self.in_enum = False      
# 
#     def visit_field_name(self, node):
#         self.in_enum = node.astext().startswith('enum') 
# 
#     def visit_field_body(self, node):
#         if self.in_enum:   
#             enum = {}          
#             idx = node.first_child_matching_class(nodes.field_list)
#             if idx is not None:
#                 items = node.children[idx].findall(nodes.field)
#                 for f in items:
#                     name = list(f.findall(nodes.field_name))[0].astext().strip()
#                     value = list(f.findall(nodes.field_body))[0].astext().strip()
#                     enum[name] = value
#             self.enum = enum

# class Control(rst.Directive):
# 
#     has_content = True
#     required_arguments = 1
# 
#     def run(self):
#         # print('Control Name', self.arguments)
#         node = ControlNode()
#         node.name = self.arguments[0] if len(self.arguments) else None
# 
#         self.state.nested_parse(self.content, self.content_offset, node)
#         idx = node.first_child_matching_class(nodes.field_list)
#         if idx is not None:
#             visitor = ControlEnumVistor(self.state.document)
#             node.children[idx].walk(visitor)
#             node.enum = visitor.enum
#             node.children.remove(node.children[idx])
# 
#         node.description = node.astext()
#         node.children = []
#         return [node]
# 
# 
# directives.register_directive("control", Control)

# class FluidObjectVisitor(nodes.SparseNodeVisitor):
# 
#     def __init__(self, document):
#         nodes.SparseNodeVisitor.__init__(self,document)
#         self.obj = {}
#         self.current_field = None
#         self.controls = {}
#         self.messages = {}
# 
#     def visit_field(self, node):
# 
#         self.current_field = {}
# 
#     def depart_field(self,node):
#         if self.current_field:
#             self.obj[self.current_field["key"]] = self.current_field["value"]
# 
#     def visit_field_name(self, node):
#         self.current_field["key"] = node.astext()
#         raise nodes.SkipNode
# 
#     def visit_field_body(self, node):
#         self.current_field["value"] = node.astext()
#         raise nodes.SkipNode
# 
#     def visit_ControlNode(self, node):
#         self.controls[node.name] = {"description": node.description}
#         if(node.enum): self.controls[node.name]['enum'] = node.enum
#         raise nodes.SkipNode
# 
#     def visit_MessageNode(self, node):
#         self.messages[node.name] = {"description": node.description, "args": node.args}
#         raise nodes.SkipNode
# 
 
pattern = re.compile("(.+)\s+(.+)")
# message_pattern = re.compile("message\s+(.+)")

def control(name,node,obj):
    obj['parameters'][name] = {'description':None}    
    o = obj['parameters'][name]
        
    #control might have enum options        
    idx = node.first_child_matching_class(nodes.field_list)
    if idx is not None:
        items = node.children[idx].findall(nodes.field)
        for f in items:
            if pattern.match(f.astext().strip()).group(1) == 'enum':
                name = list(f.findall(nodes.field_name))[0].astext().strip()
                value = list(f.findall(nodes.field_body))[0].astext().strip()
                o['enum'] = {}
                o['enum'][name] = value
        node.children.remove(node.children[idx])        
                
    o['description'] = node.astext().strip()
    
    # print('control',name,o)
    return obj

def message(name,node,obj):
    obj['messages'][name] = {'description':None }    
    o = obj['messages'][name]
    
    #message might have args         
    idx = node.first_child_matching_class(nodes.field_list)
    if idx is not None:
        visitor = MessageArgPartsVistor(node.document)
        node.children[idx].walkabout(visitor)
        o['args'] = visitor.args
        node.children.remove(node.children[idx])
        
    o['description'] = node.astext()
    return obj
    # print('message',name,o)

def parse(content):
    parser = rst.Parser(inliner=NoInliner())
    components = (rst.Parser,)
    
    settings = docutils.frontend.OptionParser(
        components=components
    ).get_default_values()
    
    document = docutils.utils.new_document("<rst-doc>", settings=settings)
    
    parser.parse(content, document)
    
    
    def find_children(node,cls):
        return node.children[0].findall(cls,descend=False,siblings=True)
    
    fieldlists = find_children(document,nodes.field_list) 
    # document.children[0].findall(nodes.field_list,descend=False,siblings=True)
    object = {'parameters':{},'messages':{}}
    for fl in fieldlists:
        for f in find_children(fl,nodes.field): 
            # print(f.astext())
            name = list(find_children(f,nodes.field_name))[0]
            content = list(find_children(f,nodes.field_body))[0]
            parts = pattern.match(name.astext().strip())
            if parts:
                globals()[parts.group(1)](parts.group(2),content, object)    
            else: 
                object[name.astext().strip()] = content.astext().strip()
                # print(name.astext())

    return object
            
            
    
    # visitor = FluidObjectVisitor(document)
    # document.walkabout(visitor)
    # print(document.pformat())
    # obj = visitor.obj
    # obj["parameters"] = visitor.controls
    # obj["messages"] = visitor.messages
    # # print(obj)
    # return copy.deepcopy(obj)
