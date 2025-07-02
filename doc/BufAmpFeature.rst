:digest: Buffer-Based Amplitude Differential Feature
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation
:see-also: BufAmpSlice, AmpSlice, BufAmpGate, AmpGate, BufNoveltyFeature, BufOnsetFeature
:max-seealso: peakamp~, meter~, snapshot~, slide~
:description: Calculate the amplitude differential feature used by :fluid-obj:`BufAmpSlice`.
:discussion: 
    :fluid-obj:`BufAmpSlice` uses the differential between a fast and a slow envelope follower to determine changes in amplitude. This object calculates the amplitude differential and copies it to an output buffer.

:output: Nothing, as the destination buffer is declared in the function call.


:control source:

   The |buffer| to use as the source material for the amplitude differential curve to be computed. Contrary to |BufAmpSlice| the different channels of multichannel buffers will not be summed but will be processed sequentially.

:control startFrame:

  The starting point for analysis in the source (in frames).

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, the starting channel to analyse.

:control numChans:

   For multichannel srcBuf, the number of channels to analyse.

:control numChans:

   For multichannel sources, how many channels should be summed.

:control features:

   The buffer where the amplitude differential feature will be copied to.

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

   Controls the zero-padding added to either end of the source buffer or segment. Padding ensures all values are analysed. Possible values are:
   
   :enum:

      :0:
         No padding - The first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function.
   
      :1: 
         Half the window size - The first sample is centred in the analysis window ensuring that the start and end of the segment are accounted for in the analysis.
   
      :2: 
         Window size minus the hop size - Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.

:control action:

   A Function to be evaluated once the offline process has finished and indices instance variables have been updated on the client side. The function will be passed indices as an argument.