:digest: Buffer-Based Transient Extractor
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: Transients, BufHPSS, BufSines
:description: A transient extractor on buffers
:discussion: 
   It implements declicking algorithm from chapter 5 of 'Digital Audio Restoration' by Godsill, Simon J., Rayner, Peter J.W. with some bespoke improvements on the detection function tracking.

   The algorithm will take a buffer in, and will divide it in two outputs:
     * the transients, estimated from the signal and extracted from it;
     * the remainder of the material, as estimated by the algorithm.

   	The whole process is based on the assumption that a transient is an element that is deviating from the surrounding material, as sort of click or anomaly. The algorithm then estimates what should have happened if the signal had followed its normal path, and resynthesises this estimate, removing the anomaly which is considered as the transient.

:process: This is the method that calls for the transient extraction to be performed on a given source buffer.
:output: Nothing, as the various destination buffers are declared in the function call.


:control source:

   The index of the buffer to use as the source material to be decomposed through the NMF process. The different channels of multichannel buffers will be processing sequentially.

:control startFrame:

   Where in the srcBuf should the NMF process start, in sample.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel should be processed first.

:control numChans:

   For multichannel srcBuf, how many channel should be processed.

:control transients:

   The index of the buffer where the extracted transient component will be reconstructed.

:control residual:

   The index of the buffer where the estimated continuous component will be reconstructed.

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

   The averaging window of the error detection function. It needs smoothing as it is very jittery. The longer the window, the less precise, but the less false positive.

:control clumpLength:

   The window size in sample within which positive detections will be clumped together to avoid overdetecting in time.

:control action:

   A Function to be evaluated once the offline process has finished and all Buffer's instance variables have been updated on the client side. The function will be passed [transients, residual] as an argument.

