import re

def derive_learn_link(object_name):
    """
    Derive a url of the relevant reference in the learn platform from the object name.
    Uses a regular expression to capture oddballs where you want to keep "Buf" as a prefix to the object name.
    """

    # If you need to add an edge case add another item to this regex
    m = re.search('(?:Buf)(?!NMF|Compose|Flatten|Scale|STFT)(.+)', object_name)
    if m:
        return m.group(1).lower()
    else:
        return object_name.lower()