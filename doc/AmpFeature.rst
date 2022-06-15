:digest: Realtime Amplitude Differential Feature
:species: transformer
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation
:see-also: AmpGate, AmpSlice, OnsetFeature, NoveltyFeature
:description: Calculate the amplitude differential feature in realtime.
:discussion: 
    :fluid-obj:`AmpSlice` uses the differential between a fast and a slow envelope follower to determine changes in amplitude. This object calculates the amplitude differential and copies it to an output buffer.

:process: The audio rate in, control rate out version of the object.
:output: A KR signal of the feature.

:control in:

    The audio to be processed.

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


