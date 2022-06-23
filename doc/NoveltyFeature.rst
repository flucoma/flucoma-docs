:digest: Realtime Novelty Feature
:species: descriptor
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulation
:see-also: NoveltySlice, AmpFeature, OnsetFeature
:description: Calculates the novelty feature of audio in realtime.
:discussion: 
   Calculate novelty in realtime, the feature used by :fluid-obj:`NoveltySlice` to perform segmentation. 
   
   Novelty derived by running a kernel across the diagonal of the similarity matrix. It implements the seminal results published in  'Automatic Audio Segmentation Using a Measure of Audio Novelty' by J Foote.

:process: The audio rate version of the object.
:output: A KR signal of the feature.

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

   The granularity of the window in which the algorithm looks for change in samples. A small number will be sensitive to short term changes, and a large number should look for long term changes.

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