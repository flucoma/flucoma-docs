:digest: Real-time Pitch Descriptor
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit, Classes/Pitch
:see-also: BufPitch, MFCC, MelBands, Loudness, SpectralShape
:description: Three popular pitch descriptors, all of which compute frequency and the confidence that a pitch is present.
:discussion: 

  :fluid-obj:`Pitch` returns both `pitch` and `confidence` values. When no pitch can be detected, a pitch of 0 Hz is returned (or -999.0 when the unit is in MIDI note mode).
  
  For information about the pitch descriptor algorithms, see the `algorithm` parameter below.
  
  The "confidence" output is a value between 0 and 1 indicating how confident the algorithm is *that there is* a pitch. In effect this can be an estimation of how "noisy" (closer to 0) or "harmonic" (closer to 1) the spectrum is.
  
:process: The audio rate in, control rate out version of the object.

:output: The two descriptors: [pitch, confidence]. The latency is windowSize.

:control in:

   The audio to be processed.

:control algorithm:

   The algorithm to estimate the pitch. (The default is 2.) The options are:

   :enum:

      :0:
         Cepstrum: Returns a pitch estimate as the location of the highest peak (not including DC) in the Cepstrum of the signal.

      :1:
         Harmonic Product Spectrum: Implements the Harmonic Product Spectrum algorithm for pitch detection . See e.g. A. Lerch, "An Introduction to Audio Content Analysis: Applications in Signal Processing and Music Informatics." John Wiley & Sons, 2012.https://onlinelibrary.wiley.com/doi/book/10.1002/9781118393550

      :2:
         YinFFT: Implements the frequency domain version of the YIN algorithm, as described in P. M. Brossier, "Automatic Annotation of Musical Audio for Interactive Applications.” QMUL, London, UK, 2007. See also https://essentia.upf.edu/documentation/reference/streaming_PitchYinFFT.html

:control minFreq:

   The minimum frequency that the algorithm will search for. This sets the lowest value that can be generated. The default is 20.

:control maxFreq:

   The maximum frequency that the algorithm will search for. This sets the highest value that can be generated. The default is 10000.

:control unit:

   The unit of the pitch output. The default of 0 indicates to output in Hz. A value of 1 will output MIDI note values.

:control windowSize:

   The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.
