:digest: Buffer Compositing Utility
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulationToolkit, Classes/Buffer
:see-also: 
:description: A flexible utility for combining the contents of buffers. It can be used for thing like mixing down multichannel buffers, or converting from left-right stereo to mid-side. It is used extensively in the example code of Fluid Decomposition.
:discussion: It is important to understand the rules used for determining the final desintinaiton buffer dimensions to get the most out of this object. If needs be, the destination buffer will be resized to the maxima of the requsted source numFrames and numChannels. Frames will be written up to the limit of actually available samples (meaning you can create zero padding); channels  will be written modulo the available channels, taking into account the channel offsets, meaning you can have channels repeat or loop into the source buffer's channels. See the examples below.
:process: This method triggers the compositing.
:output: Nothing, as the destination buffer is declared in the function call.


:control source:

   The bufNum of the source buffer.

:control startFrame:

   The starting point (in samples) from which to copy in the source buffer.

:control numFrames:

   The duration (in samples) to copy from the source buffer. The default (-1) copies the full lenght of the buffer.

:control startChan:

   The first channel from which to copy in the source buffer.

:control numChans:

   The number of channels from which to copy in the source buffer. This parameter will wrap around the number of channels in the source buffer. The default (-1) copies all of the buffer's channel.

:control gain:

   The gain applied to the samples to be copied from the source buffer.

:control destination:

   The bufNum of the destination buffer.

:control destStartFrame:

   The time offset (in samples) in the destination buffer to start writing the source at. The destination buffer will be resized if the portion to copy is overflowing.

:control destStartChan:

   The channel offest in the destination buffer to start writing the source at. The destination buffer will be resized if the number of channels to copy is overflowing.

:control destGain:

   The gain applied to the samples in the region of the destination buffer over which the source is to be copied. The default value (0) will overwrite that section of the destination buffer, and a value of 1.0 would sum the source to the material that was present.

