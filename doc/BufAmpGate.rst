:digest: Amplitude-based Gating Slicer for Buffers
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: AmpGate, BufAmpSlice, BufOnsetSlice, BufNoveltySlice, BufTransientSlice
:description: This class implements an amplitude-based slicer, with various customisable options and conditions to detect absolute amplitude changes as onsets and offsets.
:discussion: 
   FluidBufAmpGate is based on an envelop follower on a highpassed version of the signal, which is then going through a Schmidt trigger and state-aware time contraints. The example code below is unfolding the various possibilites in order of complexity.

   The process will return a two-channel buffer with the addresses of the onset on the first channel, and the address of the offset on the second channel.

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

:control rampUp:

   The number of samples the envelope follower will take to reach the next value when raising.

:control rampDown:

   The number of samples the envelope follower will take to reach the next value when falling.

:control onThreshold:

   The threshold in dB of the envelope follower to trigger an onset, aka to go ON when in OFF state.

:control offThreshold:

   The threshold in dB of the envelope follower to trigger an offset, , aka to go ON when in OFF state.

:control minSliceLength:

   The length in samples that the Slice will stay ON. Changes of states during that period will be ignored.

:control minSilenceLength:

   The length in samples that the Slice will stay OFF. Changes of states during that period will be ignored.

:control minLengthAbove:

   The length in samples that the envelope have to be above the threshold to consider it a valid transition to ON. The Slice will start at the first sample when the condition is met. Therefore, this affects the latency.

:control minLengthBelow:

   The length in samples that the envelope have to be below the threshold to consider it a valid transition to OFF. The Slice will end at the first sample when the condition is met. Therefore, this affects the latency.

:control lookBack:

   The length of the buffer kept before an onset to allow the algorithm, once a new Slice is detected, to go back in time (up to that many samples) to find the minimum amplitude as the Slice onset point. This affects the latency of the algorithm.

:control lookAhead:

   The length of the buffer kept after an offset to allow the algorithm, once the Slice is considered finished, to wait further in time (up to that many samples) to find a minimum amplitude as the Slice offset point. This affects the latency of the algorithm.

:control highPassFreq:

   The frequency of the fourth-order Linkwitz–Riley high-pass filter (https://en.wikipedia.org/wiki/Linkwitz%E2%80%93Riley_filter). This is done first on the signal to minimise low frequency intermodulation with very fast ramp lengths. A frequency of 0 bypasses the filter.

:control maxSize:

   How large can the buffer be for time-critical conditions, by allocating memory at instantiation time. This cannot be modulated.

