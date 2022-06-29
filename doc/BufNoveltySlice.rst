:digest: Buffer-Based Novelty-Based Slicer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulation
:see-also: NoveltySlice, BufAmpSlice, BufOnsetSlice, BufTransientSlice
:description: A non-realtime slicer using an algorithm assessing novelty in the signal to estimate the slicing points.
:discussion: 
   A novelty curve is derived from running a kernel across the diagonal of the similarity matrix, and looking for peaks of changes. It implements the seminal results published in  'Automatic Audio Segmentation Using a Measure of Audio Novelty' by J Foote.

   The process will return a buffer which contains indices (in sample) of estimated starting points of different slices.

   .. only_in:: sc

      The argument for ``algorithm`` can be passed as an integer (see table below), or as one of the following symbols: ``\spectrum``, ``\mfcc``, ``\chroma``, ``\pitch``, or ``\loudness``. 

:process: This is the method that calls for the slicing to be calculated on a given source buffer.
:output: Nothing, as the various destination buffers are declared in the function call.


:control source:

   The index of the buffer to use as the source material to be sliced through novelty identification. The different channels of multichannel buffers will be summed.

:control startFrame:

   Where in the srcBuf should the slicing process start, in sample.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel should be processed.

:control numChans:

   For multichannel srcBuf, how many channels should be summed.

:control indices:

   The index of the buffer where the indices (in sample) of the estimated starting points of slices will be written. The first and last points are always the boundary points of the analysis.

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

:control threshold:

   The normalised threshold, between 0 and 1, on the novelty curve to consider it a segmentation point.

:control filterSize:

   The size of a smoothing filter that is applied on the novelty curve. A larger filter size allows for cleaner cuts on very sharp changes.

:control minSliceLength:

   The minimum duration of a slice in number of hopSize.

:control windowSize:

   The window size. As novelty estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

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

:control action:

   A Function to be evaluated once the offline process has finished and indices instance variables have been updated on the client side. The function will be passed indices as an argument.

