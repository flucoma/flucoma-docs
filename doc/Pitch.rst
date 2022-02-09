:digest: A Selection of Pitch Descriptors in Real-Time
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit, Classes/Pitch
:see-also: BufPitch, MFCC, MelBands, Loudness, SpectralShape
:description: Three popular pitch descriptors, computed as frequency and the confidence in its value.
:discussion: The process will return a multichannel control steam with [pitch, confidence] values, which will be repeated if no change happens within the algorithm, i.e. when the hopSize is larger than the signal vector size. A pitch of 0 Hz is yield (or -999.0 when the unit is in MIDI note) when the algorithm cannot find a fundamental at all.
:process: The audio rate in, control rate out version of the object.
:output: A 2-channel KR signal with the [pitch, confidence] descriptors. The latency is windowSize.


:control in:

   The audio to be processed.

:control algorithm:

   The algorithm to estimate the pitch. The options are:

   :enum:

      :0:
         Cepstrum: Returns a pitch estimate as the location of the second highest peak in the Cepstrum of the signal (after DC).

      :1:
         Harmonic Product Spectrum: Implements the Harmonic Product Spectrum algorithm for pitch detection . See e.g. A. Lerch, "An Introduction to Audio Content Analysis: Applications in Signal Processing and Music Informatics." John Wiley & Sons, 2012.https://onlinelibrary.wiley.com/doi/book/10.1002/9781118393550

      :2:
         YinFFT: Implements the frequency domain version of the YIN algorithm, as described in P. M. Brossier, "Automatic Annotation of Musical Audio for Interactive Applications.” QMUL, London, UK, 2007. See also https://essentia.upf.edu/documentation/reference/streaming_PitchYinFFT.html

:control minFreq:

   The minimum frequency that the algorithm will search for an estimated fundamental. This sets the lowest value that will be generated.

:control maxFreq:

   The maximum frequency that the algorithm will search for an estimated fundamental. This sets the highest value that will be generated.

:control unit:

   The unit of the estimated value. The default of 0 is in Hz. A value of 1 will convert to MIDI note values.

:control windowSize:

   The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

