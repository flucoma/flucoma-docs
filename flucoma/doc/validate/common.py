# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

from schema import Schema, Optional 

not_yet_documented = """

.. warning:: Not yet documented 

"""

def PermissveSchema(schema): 
    """
    Make a Schema cheerfully permissive by passing through any extra keys it encounters. The code for this is simple enough but distracting if done inline. Note that this is totally assuming that the schema is a dict, which is true for our purposes here but narrower than what the library actually affords
    """
    return(Schema({
            **schema, # all the original stuff
            **{Optional(object):object} # _maybe_ other things, in which case just pass
        }))
