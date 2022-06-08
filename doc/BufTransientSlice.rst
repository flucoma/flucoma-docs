:digest: Buffer-Based Transient-Based Slicer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulationToolkit,
:see-also: TransientSlice, BufOnsetSlice, BufNoveltySlice
:description: Transient-based slice extractor on buffers
:discussion: 

  BufTransientSlice identifies slice points in a buffer by implementing a "de-clicking" algorithm based on the assumption that a transient is a sample or series of samples that are anomalous when compared to surrounding material. It creates an autoregressive model of the samples' time series, so that when a given sample doesn't fit the model (it's "error" or anomalous-ness) goes above ``threshFwd`` it is determined to be a transient and a slice point is identified. 
  
  The series of samples determined to be a transient will continue until the error goes below ``threshBack``, indicating that the samples are again more in-line with the autoregressive model.
   
  The process will return an ``indices`` buffer which contains the indices (in samples) of estimated starting points of the different slices.

  The algorithm implemented is from chapter 5 of "Digital Audio Restoration" by Godsill, Simon J., Rayner, Peter J.W. with some bespoke improvements on the detection function tracking.

:process: This is the method that calls for the slicing to be calculated on a given source buffer.
:output: Nothing, as the destination buffer is declared in the function call.

:control source:

   The |buffer| to use as the source material to detect transients in. The different channels of multichannel buffers will be summed.

:control startFrame:

  Where in ``source`` the process should begin, in samples. The default is 0.

:control numFrames:

  How many frames of ``source`` should be process. The default of -1 indicates to process through the end of the buffer.

:control startChan:

  For multichannel ``source``, which channel to begin processing from.

:control numChans:

  For multichannel ``source``, how many channels to process. The default of -1 indicates to process through the last channel in the buffer. Multichannel analyses are summed to mono before processing.

:control indices:

   The buffer where the indices (in samples) of the estimated starting points of slices will be written.

:control order:

  How many previous samples are used by the algorithm to create the autoregressive model of the signal. The higher the order, the more accurate is its spectral definition, improving low frequency resolution (similar to an FFT but it differs in that it is not connected to temporal resolution).

:control blockSize:

  The size of audio chunk (in samples) on which the process is operating. This determines the maximum duration (in samples) of a detected transient, which cannot be more than than half ``blockSize``.

:control padSize:

  The size (in samples) of analysis on each side of `` blockSize`` used to avoid boundary issues.

:control skew:

 The nervousness of the bespoke detection function with values from -10 to 10. It allows to decide how peaks are amplified or smoothed before the thresholding. High values increase the sensitivity to small variations.

:control threshFwd:

 The threshold of the onset of the smoothed error function. It allows tight start of the identification of the anomaly as it proceeds forward.

:control threshBack:

 The threshold of the offset of the smoothed error function. As it proceeds backwards in time, it allows tight ending of the identification of the anomaly.

:control windowSize:

 The averaging window of the error detection function. It needs smoothing as it is very jittery. The longer the window, the less precise, but the less false positive.

:control clumpLength:

 The window size in samples within which anomalous samples will be clumped together to avoid over detecting in time. This is similar to setting a minimum slice length.

:control minSliceLength:

   The minimum duration of a slice in samples.

:control action:

   A Function to be evaluated once the offline process has finished and indices instance variables have been updated on the client side. The function will be passed indices as an argument.
