:digest: A Scaling Processor for Buffers
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit, Guides/FluidBufMultiThreading
:see-also: 
:description: 
   This class implements a simple Buffer preprocessor, by scaling its values. It draws a simple translation from inputLow to outputLow, and from inputHigh to outputHigh.

   The process will return a buffer with the same size and shape than the requested range.



:control source:

   This is the method that calls for the scaling to be calculated on a given source buffer.

:control startFrame:

   The starting point (in samples) from which to copy in the source buffer.

:control numFrames:

   The duration (in samples) to copy from the source buffer. The default (-1) copies the full lenght of the buffer.

:control startChan:

   The first channel from which to copy in the source buffer.

:control numChans:

   The number of channels from which to copy in the source buffer. This parameter will wrap around the number of channels in the source buffer. The default (-1) copies all of the buffer's channel.

:control destination:

   The index of the buffer to use as the destination for the processed material.

:control inputLow:

   The low reference point of the input. it will be scaled to yield outputLow at the output

:control inputHigh:

   The high reference point of the input. it will be scaled to yield outputHigh at the output

:control outputLow:

   The output value when the input is inputLow

:control outputHigh:

   The output value when the input is inputHigh

:control clipping:

   Optional clipping of the input (and therefore of the output). 0 is none. 1 caps the lowest input at inputLow. 2 caps the highest input at inputHigh, 3 caps both input low and high value within the described range.

