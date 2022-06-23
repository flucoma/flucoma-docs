:digest: Buffer-Based Amplitude Differential Feature
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation
:see-also: BufAmpSlice, BufNoveltyFeature, BufAmpFeature, BufOnsetFeature
:description: Calculate the amplitude differential feature used by :fluid-obj:`BufAmpSlice`.
:discussion: 
    :fluid-obj:`BufAmpSlice` uses the differential between a fast and a slow envelope follower to determine changes in amplitude. This object calculates the amplitude differential and copies it to an output buffer.

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

   For multichannel sources, how many channels should be summed.

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

:control padding:

   Controls the zero-padding added to either end of the source buffer or segment. Possible values are 0 (no padding), 1 (default, half the window size), or 2 (window size - hop size). Padding ensures that all input samples are completely analysed: with no padding, the first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function. Mode 1 has the effect of centering the first sample in the analysis window and ensuring that the very start and end of the segment are accounted for in the analysis. Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.

:control action:

   A Function to be evaluated once the offline process has finished and indices instance variables have been updated on the client side. The function will be passed indices as an argument.