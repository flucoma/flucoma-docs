:digest: Gate Detection on a Buffer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation
:see-also: AmpGate, BufAmpSlice, AmpSlice, BufOnsetSlice, BufNoveltySlice, BufTransientSlice
:max-seealso: peakamp~, meter~, snapshot~, slide~
:description: Absolute amplitude threshold gate detector on audio in a buffer

:discussion: 

   BufAmpGate outputs a two-channel buffer containing open and close positions of the gates. Each frame of the buffer contains an onset (opening) position on channel 0 and the corresponding offset (closing) position on channel 1 (both in samples). The buffer will have as many frames as gate events detected.
   
   The gate detects an onset (opens) when the internal envelope follower (controlled by ``rampUp`` and ``rampDown``) goes above a specified ``onThreshold`` (in dB) for at least ``minLengthAbove`` samples. The gate will stay open until the envelope follower goes below ``offThreshold`` (in dB) for at least ``minLengthBelow`` samples, which triggers an offset.

:output: Nothing, as the destination buffer is declared in the function call.

:control source:

   The buffer to analyse for gate information. Multichannel buffers will be summed to mono for analysis.

:control startFrame:

   Where in ``source`` to begin the analysis (in samples). The default is 0.

:control numFrames:

   How many frames (audio samples) to analyse. The default of -1 indicates to analyse through end of the buffer

:control startChan:

   For multichannel sources, at which channel to begin the analysis. The default is 0.

:control numChans:

   For multichannel sources, how many channels should be included in the analysis (starting from ``startChan``). The default of -1 indicates to include all the channels from ``startChan`` through the rest of the buffer. If more than one channel is specified, the channels will be summed to mono for analysis.

:control indices:

   The buffer to write the gate information into. Buffer will be resized appropriately so that each frame contains an onset (opening) position on channel 0 and the corresponding offset (closing) position on channel 1 (both in samples). The buffer will have as many frames as gate events detected.

:control rampUp:

  The number of samples the envelope follower will take to reach the next value when rising.

:control rampDown:

  The number of samples the envelope follower will take to reach the next value when falling.

:control onThreshold:

  The threshold in dB of the envelope follower to trigger an onset.

:control offThreshold:

  The threshold in dB of the envelope follower to trigger an offset.

:control minSliceLength:

  The minimum length in samples for which the gate will stay open. Changes of states during this period after an onset will be ignored.

:control minSilenceLength:

  The minimum length in samples for which the gate will stay closed. Changes of states during that period after an offset will be ignored.

:control minLengthAbove:

  The length in samples that the envelope must be above the threshold to consider it a valid onset. The onset will be triggered at the first sample when the condition is met.

:control minLengthBelow:

  The length in samples that the envelope must be below the threshold to consider it a valid offset. The offset will be triggered at the first sample when the condition is met.

:control lookBack:

  When an onset is detected, the algorithm will look in the recent past (this length in samples) for a minimum in the envelope follower to identify as the onset point. 

:control lookAhead:

  When an offset is detected, the algorithm will wait this duration (in samples) to find a minimum in the envelope follower to identify as the offset point. 
  
:control highPassFreq:

  The frequency of the fourth-order Linkwitz-Riley high-pass filter (https://en.wikipedia.org/wiki/Linkwitz%E2%80%93Riley_filter) applied to the signal to minimise low frequency intermodulation with very short ramp lengths. A frequency of 0 bypasses the filter.

:control maxSize:

  The amount of memory allocated at instantiation. It limits how other parameters can be modulated: ``minLengthBelow``, ``lookAhead``, and ``minLengthAbove + lookBack`` should not exceed ``maxSize``.