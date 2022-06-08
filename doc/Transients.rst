:digest: Real-Time Transient Modeller and Extractor
:species: transformer
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufTransients,Sines,HPSS
:description: Separate transients from a signal.
:discussion: 
   This implements a "de-clicking" algorithm based on the assumption that a transient is a sample or series of samples that are anomalous when compared to surrounding material. It creates an autoregressive model of the samples' time series (no FFT processing is used), so that when a given sample doesn't fit the model (it's "error" or anomalous-ness) goes above ``threshFwd`` it is determined to be a transient. The series of samples determined to be a transient will continue until the error goes below ``threshBack``, indicating that the samples are again more in-line with the autoregressive model. The algorithm then estimates what should have happened during the transient period if the signal had followed its normal path, and resynthesises this estimate, removing the anomaly considered as the transient.

    The algorithm will take an audio in, and will divide it in two outputs:
    	* the transients, estimated from the signal and extracted from it;
    	* the remainder of the material, as estimated by the algorithm, with the click replaced with an estimate.
    
    The algorithm implemented is from chapter 5 of "Digital Audio Restoration" by Godsill, Simon J., Rayner, Peter J.W. with some bespoke improvements on the detection function tracking.
    
:process: The audio rate version of the object.
:output: An array of two audio streams: [0] is the transient extracted, [1] is the rest. The latency between the input and the output is ``((blockSize + padSize) - order)`` samples.

:control in:

   The audio to be processed.

:control order:

   How many previous samples are used by the algorithm to create the autoregressive model of the signal. The higher the order, the more accurate is its spectral definition, improving low frequency resolution (similar to an FFT but it differs in that it is not connected to temporal resolution).

:control blockSize:

   The size of audio chunk (in samples) on which it the algorithm is operating. This determines the maximum duration (in samples) of a detected transient, which cannot be more than than half ``blockSize``. High values are more cpu intensive.

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

   The window size in sample within which positive detections will be clumped together to avoid overdetecting in time.
