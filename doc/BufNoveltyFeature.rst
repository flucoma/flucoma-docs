:digest: Buffer-Based Novelty Feature
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulation
:see-also: BufNoveltySlice, BufNoveltyFeature, BufAmpFeature, BufOnsetFeature
:description: Calculates the novelty feature of audio stored in a buffer.
:discussion:
    Calculate novelty of audio stored in a buffer, the feature used by :fluid-obj:`BufNoveltySlice` to perform segmentation. 
    
    Novelty is derived by running a kernel across the diagonal of the similarity matrix. It implements the seminal results published in  'Automatic Audio Segmentation Using a Measure of Audio Novelty' by J Foote.
    
    The process will return a buffer containing a time series that describes the novelty feature changing over time in the source buffer.

:process: This is the method that calls for the slicing to be calculated on a given source buffer.
:output: Nothing, as the various destination buffers are declared in the function call.

:control source:

   The buffer to use as the source material to be sliced through novelty identification. The different channels of multichannel buffers will be summed.

:control startFrame:

   Where in the srcBuf should the slicing process start, in samples.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel should be processed.

:control numChans:

   For multichannel srcBuf, how many channels should be summed.

:control features:

   The buffer where the novelty feature will be written.

:control algorithm:

   The feature on which novelty is computed.

   :enum:

      :0:
         Spectrum – The magnitude of the full spectrum.

      :1:
         MFCC – 13 Mel-Frequency Cepstrum Coefficients.

      :2:
         Chroma - The contour of a 12-band chromagram.

      :3:
         Pitch – The pitch and its confidence.

      :4:
         Loudness – The true peak and loudness.

:control kernelSize:

   The granularity of the window in which the algorithm looks for change, in samples. A small number will be sensitive to short term changes, and a large number should look for long term changes.

:control filterSize:

   The size of a smoothing filter that is applied on the novelty curve. A larger filter size allows for cleaner cuts on very sharp changes.

:control windowSize:

   The window size. As novelty estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally.

:control hopSize:

   The window hop size. As novelty estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts.

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

:control maxKernelSize:

   This cannot be modulated.

:control maxFilterSize:

   This cannot be modulated.

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

