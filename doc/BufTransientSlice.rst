:digest: Buffer-Based Transient-Based Slicer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulationToolkit,
:see-also: TransientSlice, BufOnsetSlice, BufNoveltySlice
:description: Transient-based slice extractor on buffers
:discussion: 
   This relies on the same algorithm as BufTransients using clicks/transients/derivation/anomalies in the signal to estimate the slicing points.

   The process will return a buffer which contains indices (in sample) of estimated starting points of the different slices.

:process: This is the method that calls for the slicing to be calculated on a given source buffer.
:output: Nothing, as the destination buffer is declared in the function call.


:control source:

   The index of the buffer to use as the source material to be sliced through transient identification. The different channels of multichannel buffers will be summed.

:control startFrame:

   Where in the srcBuf should the slicing process start, in sample.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel should be processed.

:control numChans:

   For multichannel srcBuf, how many channel should be summed.

:control indices:

   The index of the buffer where the indices (in sample) of the estimated starting points of slices will be written. The first and last points are always the boundary points of the analysis.

:control order:

   The order in samples of the impulse response filter used to model the estimated continuous signal. It is how many previous samples are used by the algorithm to predict the next one as reference for the model. The higher the order, the more accurate is its spectral definition, not unlike fft, improving low frequency resolution, but it differs in that it is not conected to its temporal resolution.

:control blockSize:

   The size in samples of frame on which it the algorithm is operating. High values are more cpu intensive, and also determines the maximum transient size, which will not be allowed to be more than half that lenght in size.

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

   The window size in sample within which positive detections will be clumped together to avoid overdetecting in time.

:control minSliceLength:

   The minimum duration of a slice in samples.

:control action:

   A Function to be evaluated once the offline process has finished and indices instance variables have been updated on the client side. The function will be passed indices as an argument.

