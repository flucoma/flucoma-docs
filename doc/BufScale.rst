:digest: A Scaling Processor for Buffers
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Guides/FluidBufMultiThreading
:see-also: BufThresh, BufCompose, BufFlatten
:description: Scale |buffer| values from an input range to an output range.
:discussion: This object is for scaling |buffer| values. It copies data from a source |buffer| to a destination |buffer|, scaling the source from an input range to an output range.


:control source:

   This is the method that calls for the scaling to be calculated on a given source buffer.

:control startFrame:

   The starting point (in samples) from which to copy in the source |buffer|.

:control numFrames:

   The duration (in samples) to copy from the source |buffer|. The default (-1) copies the full length of the |buffer|.

:control startChan:

   The first channel from which to copy in the source |buffer|.

:control numChans:

   The number of channels from which to copy in the source |buffer|. This parameter will wrap around the number of channels in the source |buffer|. The default (-1) copies all |buffer| channels.

:control destination:

   The destination |buffer|.

:control inputLow:

   The low reference value of the input scaling range.

:control inputHigh:

   The high reference value of the input scaling range.

:control outputLow:

   The low reference value of the output scaling range.

:control outputHigh:

   The high reference value of the output scaling range.

:control clipping:

   Optional clipping of the input (and therefore of the output). 0 is none. 1 clips the lowest input at inputLow. 2 caps the highest input at inputHigh, 3 caps both input low and high value within the described range.

