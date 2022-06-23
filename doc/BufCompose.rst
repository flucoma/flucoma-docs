:digest: Buffer Compositing Utility
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulation, Classes/Buffer
:see-also: BufSelect, BufSelectEvery
:max-seealso: poke~, peek~, index~, buffer~
:description: 
   A utility for manipulating the contents of buffers.

:discussion: 
   This object is the swiss army knife for manipulating buffers and their contents. By specifying ranges of samples and channels to copy, as well as destination and source gains it can provide a powerful interface for performing actions such as a Left/Right to Mid/Side conversion and mixing down multichannel audio

:process: This method triggers the compositing.

:output: Nothing, as the destination buffer is declared in the function call.


:control source:

   The name of the source buffer.

:control startFrame:

   The starting point (in samples) from which to copy in the source buffer.

:control numFrames:

   The duration (in samples) to copy from the source buffer. The default (-1) copies the full length of the buffer.

:control startChan:

   The first channel from which to copy in the source buffer.

:control numChans:

   The number of channels from which to copy in the source buffer. This parameter will wrap around the number of channels in the source buffer. The default (-1) copies all of the buffer's channels.

:control gain:

   The gain applied to the samples to be copied from the source buffer.

:control destination:

   The name of the destination buffer.

:control destStartFrame:

   The time offset (in samples) in the destination buffer to start writing the source at. The destination buffer will be resized if the portion to copy is overflowing.

:control destStartChan:

   The channel offset in the destination buffer to start writing the source at. The destination buffer will be resized if the number of channels to copy is overflowing.

:control destGain:

   The gain applied to the samples in the region of the destination buffer over which the source is to be copied. The default value (0) will overwrite that section of the destination buffer, and a value of 1.0 would sum the source to the material that was present.

