:digest: Perform a Short-Time Fourier Transform on one channel of a buffer
:species: buffer-proc
:sc-categories: FluidCorpusManipulation
:sc-related: Classes/Buffer
:see-also: 
:description: 
   Performs either a forward or inverse Short-Time Fourier Transform (STFT) on a single channel source |buffer|. In the forward case, resulting magnitudes and phases can be written to output buffers. In the inverse case, these buffers can be used to reconstruct the original source into a new buffer.

   The magntude and phase buffers are laid out as (number of hops, number of bins). The number of hops is a function of the source length and the hop size. The number of bins is (1 + (fft size / 2)).

   The object is restricted to analysing a single source channel, because the channel counts of the magntude and phase buffers would quickly get out of hand otherwise.



:control source:

   The |buffer| to use for the forward STFT

:control startFrame:

   The starting point for analysis in the source (in samples)

:control numFrames:

   The duration (in samples) to analyse

:control startChan:

   The channel to analyse

:control magnitude:

   The |buffer| to write magnitudes to in the forward case, or read from in the inverse case. This is optional for the forward transform, mandatory for the inverse.

:control phase:

   The |buffer| to write phases to in the forward case, or read from in the inverse case. This is optional for the forward transform, mandatory for the inverse.

:control resynthesis:

   The |buffer| to write re-synthesised data to in the inverse case. Ignored for the forward transform. Mandatory in the inverse case.

:control inverse:

   When set to 1, an inverse STFT is performed, and the resynthesised data is written to the resynthesis buffer using overlap-add.

:control windowSize:

   The number of source samples that are analysed at once.

:control hopSize:

   How many samples there are in-between analysis windows. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will use the next power of 2 equal or above the windowSize. For this object it is effectively capped at 65536.

:control padding:

   Controls the zero-padding added to either end of the source buffer or segment. Possible values are 0 (no padding), 1 (default, half the window size), or 2 (window size - hop size). Padding ensures that all input samples are completely analysed: with no padding, the first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function. Mode 1 has the effect of centering the first sample in the analysis window and ensuring that the very start and end of the segment are accounted for in the analysis. Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.

