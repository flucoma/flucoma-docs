:digest: Buffer-Based Amplitude Differential Feature
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: AmpGate, BufAmpSlice, BufOnsetSlice, BufNoveltySlice, BufTransientSlice
:description: Calculate the amplitude differential feature used by both :fluid-obj:`BufAmpSlice`.
:discussion: 
    :fluid-obj:`BufAmpSlice` uses the differential of a fast and a slow envelope follower to determine changes in amplitude. This object calculates the amplitude differential and copies to an output buffer.

:output: Nothing, as the destination buffer is declared in the function call.


:control source:

   The index of the buffer to use as the source material to be sliced through novelty identification. The different channels of multichannel buffers will be summed.

:control startFrame:

   Where in the srcBuf should the slicing process start, in sample.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel sources, which channel should be processed.

:control numChans:

   For multichannel sources, how many channel should be summed.

:control features:

   The index of the buffer where the amplitude differential feature will be copied to.

:control fastRampUp:

   The number of samples the relative envelope follower will take to reach the next value when raising. Typically, this will be faster than slowRampUp.

:control fastRampDown:

   The number of samples the relative envelope follower will take to reach the next value when falling. Typically, this will be faster than slowRampDown.

:control slowRampUp:

   The number of samples the absolute envelope follower will take to reach the next value when raising.

:control slowRampDown:

   The number of samples the absolute envelope follower will take to reach the next value when falling.

:control floor:

   The level in dB the slowRamp needs to be above to consider a detected difference valid, allowing to ignore the slices in the noise floor.

:control highPassFreq:

   The frequency of the fourth-order Linkwitz–Riley high-pass filter (https://en.wikipedia.org/wiki/Linkwitz%E2%80%93Riley_filter). This is done first on the signal to minimise low frequency intermodulation with very fast ramp lengths. A frequency of 0 bypasses the filter.


