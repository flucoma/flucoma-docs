:digest: Gate Detection on a Signal
:species: slicer
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation
:see-also: BufAmpGate, AmpSlice, BufAmpSlice, OnsetSlice, NoveltySlice, TransientSlice
:max-seealso: peakamp~, meter~, snapshot~, slide~
:description: Absolute amplitude threshold gate detector on a realtime signal

:discussion: 
   AmpGate outputs an audio-rate, single-channel signal that is either 0, indicating the gate is closed, or 1, indicating the gate is open. The gate detects an onset (opens) when the internal envelope follower (controlled by ``rampUp`` and ``rampDown``) goes above a specified ``onThreshold`` (in dB) for at least ``minLengthAbove`` samples. The gate will stay open until the envelope follower goes below ``offThreshold`` (in dB) for at least ``minLengthBelow`` samples, which triggers an offset.

   The latency between the input and the output is **max(minLengthAbove + lookBack, max(minLengthBelow,lookAhead))**.

:output: An audio stream of gate information, always either 1, indicating the gate is open, or 0, indicating the gate is closed.

:control rampUp:

   The number of samples the envelope follower will take to reach the next value when rising.

:control rampDown:

   The number of samples the envelope follower will take to reach the next value when falling.

:control onThreshold:

   The threshold in dB of the envelope follower to trigger an onset: go from 0 (closed) to 1 (open).

:control offThreshold:

   The threshold in dB of the envelope follower to trigger an offset: go from 1 (open) to 0 (closed).

:control minSliceLength:

   The minimum length in samples for which the gate will stay open. Changes of states during this period after an onset will be ignored.

:control minSilenceLength:

   The minimum length in samples for which the gate will stay closed. Changes of states during that period after an offset will be ignored.

:control minLengthAbove:

   The length in samples that the envelope must be above the threshold to consider it a valid transition to 1. The gate will change to 1 at the first sample when the condition is met. Therefore, this affects the latency (see latency equation in the description).

:control minLengthBelow:

   The length in samples that the envelope must be below the threshold to consider it a valid transition to 0. The gate will change to 0 at the first sample when the condition is met. Therefore, this affects the latency (see latency equation in the description).

:control lookBack:

   When an onset is detected, the algorithm will look in the recent past (via an internal recorded buffer of this length in samples) for a minimum in the envelope follower to identify as the onset point. This affects the latency of the algorithm (see latency equation in the description).

:control lookAhead:

   When an offset is detected, the algorithm will wait this duration (in samples) to find a minimum in the envelope follower to identify as the offset point. This affects the latency of the algorithm (see latency equation in the description).
   
:control highPassFreq:

   The frequency of the fourth-order Linkwitz-Riley high-pass filter (https://en.wikipedia.org/wiki/Linkwitz%E2%80%93Riley_filter) applied to the input signal to minimise low frequency intermodulation with very short ramp lengths. A frequency of 0 bypasses the filter.

:control maxSize:

   The size of the buffer to allocate at instantiation time for keeping track of the time-critical conditions (``minSliceLength``, ``minSilenceLength``, ``minLengthAbove``, ``minLengthBelow``, ``lookBack``, and ``lookAhead``). This cannot be modulated.
