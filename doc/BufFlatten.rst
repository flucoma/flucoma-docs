:digest: Flatten a multichannel buffer
:species: buffer-proc
:sc-categories: FluidCorpusManipulation
:sc-related: Classes/Buffer
:see-also: BufCompose, BufStats
:max-seealso: poke~, peek~, index~, buffer~
:description: 
   Flatten a multichannel |buffer| to a single channel. This can be useful to structure a buffer such that it can be added to a :fluid-obj:`DataSet`
:discussion:
   The ``axis`` argument determines how the flattening is arranged. The default value, 1, flattens channel-wise (similar to how audio files are stored), such that (if we imagine channels are rows, time positions are columns):

    ===  ===  ===
    a 1  a 2  a 3
    b 1  b 2  b 3
    c 1  c 2  c 3
    ===  ===  ===

   becomes

    ===  ===  ===  ===  ===  ===  ===  ===  ===
    a 1  b 1  c 1  a 2  b 2  c 2  a 3  b 3  c 3
    ===  ===  ===  ===  ===  ===  ===  ===  ===

   whereas with ``axis`` = 0, the buffer is flattened frame-wise, resulting in:

    ===  ===  ===  ===  ===  ===  ===  ===  ===
    a 1  a 2  a 3  b 1  b 2  b 3  c 1  c 2  c 3
    ===  ===  ===  ===  ===  ===  ===  ===  ===
    
    To learn more visit https://learn.flucoma.org/reference/bufflatten/.

:control source:

   The |buffer| to flatten.

:control startFrame:

   Where in ``source`` should the flattening process start, in samples. The default is 0.

:control numFrames:

   How many frames should be processed. The default of -1 indicates to process through the end of the buffer.

:control startChan:

   For multichannel ``source`` buffers, which channel to begin the processing. The default is 0.

:control numChans:

   For multichannel ``source`` buffers, how many channels should be processed. The default of -1 indicates to process up through the last channel in  ``source``.

:control destination:

   The |buffer| to write the flattened data to.

:control axis:

   Whether to flatten the buffer channel-wise (1) or frame-wise (0). The default is 1 (channel-wise). 
