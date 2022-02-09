:digest: Amplitude-based Detrending Slicer for Buffers
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: AmpSlice, BufAmpGate, BufOnsetSlice, BufNoveltySlice, BufTransientSlice
:description: This class implements an amplitude-based slicer,with various customisable options and conditions to detect relative amplitude changes as onsets.
:discussion: 
   FluidBufAmpSlice is based on two envelop followers on a highpassed version of the signal: one slow that gives the trend, and one fast. Each have features that will interact. The example code below is unfolding the various possibilites in order of complexity.

   The process will return a buffer which contains indices (in sample) of estimated starting points of different slices.

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

:control indices:

   The index of the buffer where the indices (in sample) of the estimated starting points of slices will be written. The first and last points are always the boundary points of the analysis.

:control fastRampUp:

   The number of samples the relative envelope follower will take to reach the next value when raising. Typically, this will be faster than slowRampUp.

:control fastRampDown:

   The number of samples the relative envelope follower will take to reach the next value when falling. Typically, this will be faster than slowRampDown.

:control slowRampUp:

   The number of samples the absolute envelope follower will take to reach the next value when raising.

:control slowRampDown:

   The number of samples the absolute envelope follower will take to reach the next value when falling.

:control onThreshold:

   The threshold in dB of the relative envelope follower to trigger an onset, aka to go ON when in OFF state. It is computed on the difference between the two envelope followers.

:control offThreshold:

   The threshold in dB of the relative envelope follower to reset, aka to allow the differential envelop to trigger again.

:control floor:

   The level in dB the slowRamp needs to be above to consider a detected difference valid, allowing to ignore the slices in the noise floor.

:control minSliceLength:

   The length in samples that the Slice will stay ON. Changes of states during that period will be ignored.

:control highPassFreq:

   The frequency of the fourth-order Linkwitz–Riley high-pass filter (https://en.wikipedia.org/wiki/Linkwitz%E2%80%93Riley_filter). This is done first on the signal to minimise low frequency intermodulation with very fast ramp lengths. A frequency of 0 bypasses the filter.

