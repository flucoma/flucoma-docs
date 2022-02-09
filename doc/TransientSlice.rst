:digest: Transient-Based Real-Time Audio Slicer
:species: slicer
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufTransientSlice, AmpSlice, NoveltySlice, OnsetSlice
:description: A real-time transient-based slice extractor
:discussion: 
   This uses same algorithm as BufTransients using clicks/transients/derivation/anomaly in the signal to estimate the slicing points.

   The process will return an audio steam with sample-long impulses at estimated starting points of the different slices.

:process: The audio rate version of the object.
:output: An audio stream with impulses at detected transients. The latency between the input and the output is (blockSize + padSize - order) samples.


:control in:

   The audio to be processed.

:control order:

   The order in samples of the impulse response filter used to model the estimated continuous signal. It is how many previous samples are used by the algorithm to predict the next one as reference for the model. The higher the order, the more accurate is its spectral definition, not unlike fft, improving low frequency resolution, but it differs in that it is not connected to its temporal resolution.

:control blockSize:

   The size in samples of frame on which it the algorithm is operating. High values are more cpu intensive, and also determines the maximum transient size, which will not be allowed to be more than half that length in size.

:control padSize:

   The size of the handles on each sides of the block simply used for analysis purpose and avoid boundary issues.

:control skew:

   The nervousness of the bespoke detection function with values from -10 to 10. It allows to decide how peaks are amplified or smoothed before the thresholding. High values increase the sensitivity to small variations.

:control threshFwd:

   The threshold of the onset of the smoothed error function. It allows tight start of the identification of the anomaly as it proceeds forward.

:control threshBack:

   The threshold of the offset of the smoothed error function. As it proceeds backwards in time, it allows tight ending of the identification of the anomaly.

:control windowSize:

   The averaging window of the error detection function. It needs smoothing as it is very jittery. The longer the window, the less precise, but the less false positives.

:control clumpLength:

   The window size in sample within with positive detections will be clumped together to avoid overdetecting in time.

:control minSliceLength:

   The minimum duration of a slice in samples.

