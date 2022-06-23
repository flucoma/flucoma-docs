:digest: Perform a Short-Time Fourier Transform on one channel of a buffer
:species: buffer-proc
:sc-categories: FluidCorpusManipulation
:sc-related: Classes/Buffer
:see-also: 
:description: 

   Performs either a forward or inverse Short-Time Fourier Transform (STFT) on a single channel ``source`` |buffer|. 

:discussion:

   In the forward case, resulting magnitudes and phases can be written to output buffers. In the inverse case, these buffers can be used to reconstruct the original ``source`` into a new buffer.

   The ``magnitude`` and ``phase`` buffers are laid out so the frames are the number of analysis windows in the ``source`` buffer while the channels are the different bins. The number of hops is a function of the ``source`` length and the ``hopSize``. The number of bins is **(1 + (``fftSize`` / 2))**.

   The object is restricted to analysing a single source channel, because the channel counts of the ``magnitude`` and ``phase`` buffers would quickly get out of hand otherwise.

   .. only_in:: sc

      If using an ``fftSize`` > 1024 the number of channels in the ``magnitude`` and ``phase`` buffers will be > 1024, which is the maximum number of channels a buffer can have when using |buffer|'s instance method ``loadToFloatArray``. This means you won't be able to get the values from the buffer using ``loadToFloatArray``. Instead you can use |buffer|'s instance method ``getToFloatArray``.

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

:control resynth:

   The |buffer| to write re-synthesised data to in the inverse case. Ignored for the forward transform. Mandatory in the inverse case.

:control inverse:

   When set to 1, an inverse STFT is performed, and the resynthesised data is written to the resynthesis buffer using overlap-add.

:control windowSize:

   The number of source samples that are analysed at once.

:control hopSize:

   How many samples there are in-between the start position of the analysis windows. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will use the next power of 2 equal to or above the windowSize. For this object it is effectively capped at 65536.

:control padding:

   Controls the zero-padding added to either end of the source buffer or segment. Padding ensures all values are analysed. Possible values are:
   
   :enum:

      :0:
         No padding - The first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function.
   
      :1: 
         Half the window size - The first sample is centred in the analysis window ensuring that the start and end of the segment are accounted for in the analysis.
   
      :2: 
         Window size minus the hop size - Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.
