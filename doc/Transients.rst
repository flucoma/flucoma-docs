:digest: Realtime Transient Modeller and Extractor
:species: transformer
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation
:see-also: BufTransients, Sines, HPSS
:description: Separate transients from a signal.
:discussion: 

   This implements a "de-clicking" algorithm based on the assumption that a transient is a sample or series of samples that are anomalous when compared to surrounding samples. It creates a model of the time series of samples, so that when a given sample doesn't fit the model (its "error" or anomalous-ness goes above ``threshFwd``) it is determined to be a transient. The series of samples determined to be a transient will continue until the error goes below ``threshBack``, indicating that the samples are again more in-line with the model. 
   
   The algorithm then estimates what should have happened during the transient period if the signal had followed its non-anomalous path, and resynthesises this estimate to create the residual output. The transient output is ``input signal - residual signal``, such that the summed output of the object (``transients + residual``) can null-sum with the input. 

    The algorithm will take an audio in, and will divide it in two outputs:
    	* the transients, estimated from the signal and extracted from it
    	* the residual of the material with the transients replaced with an estimate.
    
    The algorithm implemented is from chapter 5 of "Digital Audio Restoration" by Godsill, Simon J., Rayner, Peter J.W. with some bespoke improvements on the detection function tracking.
    
:process: The audio rate version of the object.
:output: An array of two audio streams: [0] is the transient extracted, [1] is the rest. The latency between the input and the output is ``((blockSize + padSize) - order)`` samples.

:control in:

   The audio to be processed.

:control order:

   The number of previous samples used by the algorithm to create the model of the signal within the ``blockSize`` window of analysis. ``order`` must be less than ``blockSize``.

:control blockSize:

   The size of audio block (in samples) on which the process is operating. This determines the maximum duration (in samples) of a detected transient, which cannot be more than half of ``blockSize - order``. High values are more cpu intensive.

:control padSize:

   The size (in samples) of analysis on each side of ``blockSize`` used to provide some historical context for analysis, so that each ``blockSize`` isn't modelled completely independently of its predecessor.

:control skew:

   The nervousness of the bespoke detection function. It ranges from -10 to 10 (it has no units) representing the strength and direction of some nonlinearity applied to the detection signal which controls how peaks are amplified or smoothed before the thresholding. High values increase the sensitivity to small variations.

:control threshFwd:

   The threshold applied to the smoothed forward prediction error for determining an onset. The units are roughly in standard deviations, thus can be considered how "deviant", or anomalous, the signal must be to be detected as a transient. It allows tight identification of the start of the anomaly as it proceeds forward.

:control threshBack:

   The threshold applied to the smoothed backward prediction error for determining an offset. The units are roughly in standard deviations, thus can be considered how "deviant", or anomalous, the signal must be to be considered transient. When the smoothed error function goes below ``threshBack`` an offset is identified. As it proceeds backwards in time, it allows tight identification of the end of the anomaly.

:control windowSize:

   The averaging window of the error detection function. It needs smoothing as it is very jittery. The longer the window, the less precise, but the less false positive.

:control clumpLength:

   The window size in samples within which anomalous samples will be clumped together to avoid over-detecting in time. This is like setting a minimum transient length.
