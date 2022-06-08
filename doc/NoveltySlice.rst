:digest: Real-Time Novelty-Based Slicer
:species: slicer
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufNoveltySlice, OnsetSlice, AmpSlice, TransientSlice
:description: A real-time slicer using an algorithm assessing novelty in the signal to estimate the slicing points.
:discussion: 
   A novelty curve is derived from running a kernel across the diagonal of the similarity matrix, and looking for peak of changes. It implements the algorithm published in 'Automatic Audio Segmentation Using a Measure of Audio Novelty' by J Foote.

   The process will return an audio steam with single sample impulses at estimated starting points of the different slices.

:output: An audio stream with impulses at detected transients. The latency between the input and the output is hopSize * (((kernelSize+1)/2).asInteger + ((filterSize + 1) / 2).asInteger + 1) samples at maximum.


:control in:

   The audio to be processed.

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

   The normalised threshold, between 0 an 1, on the novelty curve to consider it a segmentation point.

:control filterSize:

   The size of a smoothing filter that is applied on the novelty curve. A larger filter filter size allows for cleaner cuts on very sharp changes.

:control minSliceLength:

   The minimum duration of a slice in number of hopSize.

:control windowSize:

   The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

:control maxKernelSize:

   This cannot be modulated.

:control maxFilterSize:

   This cannot be modulated.

