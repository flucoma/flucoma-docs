:digest: A Gate Processor for Buffers
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit, Guides/FluidBufMultiThreading
:see-also: 
:description: 
   This class implements a simple Buffer preprocessor, by replacing values under a threshold by 0s. It is part of the :fluid-topic:`CorpusManipulationToolkit`. For more explanations, learning material, and discussions on its musicianly uses, visit http://www.flucoma.org/

   The process will return a buffer with the same size and shape than the requested range.



:control source:

   The index of the buffer to use as the source material to be processed.

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

:control threshold:

   The threshold under which values will be zeroed

