# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from docutils import nodes, utils
from docutils.parsers.rst import roles

def fluid_object_role(role, rawtext, text, lineno, inliner,
                       options={}, content=[]):
    """Create a link to a FluCoMa object
    """
    options['flucoma-object'] = 1
    roles.set_classes(options)
    node = nodes.reference(rawtext,utils.unescape(text), **options)
    return [node], []

roles.register_local_role('fluid-obj', fluid_object_role)

def fluid_topic_role(role, rawtext, text, lineno, inliner,
                       options={}, content=[]):
    """Create a link to a FluCoMa topic
    """    
    options['flucoma-topic'] = 1
    roles.set_classes(options)
    node = nodes.reference(rawtext,utils.unescape(text), **options)
    return [node], []

roles.register_local_role('fluid-topic', fluid_topic_role)
