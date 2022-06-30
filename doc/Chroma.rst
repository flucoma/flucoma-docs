:digest: A histogram of pitch classes in Realtime
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Classes/FluidMFCC
:see-also: BufChroma, Pitch, Loudness, MFCC, SpectralShape
:description: This class computes a histogram of the energy contained for each pitch class across the analysis frequency range.
:discussion: 
   Also known as a chromagram, this typically allows you to get a contour of how much each semitone is represented in the spectrum over time. The number of chroma bins (and, thus, pitch classes) and the central reference frequency can be adjusted.

   The process will return a multichannel control stream of size maxNumChroma, which will be repeated if no change happens within the algorithm, i.e. when the hopSize is larger than the signal vector size.

:process: The audio rate in, control rate out version of the object.
:output: A  KR signal of maxNumChroma channels, giving the measure amplitudes for each chroma bin. The latency is windowSize.


:control in:

   The audio to be processed.

:control numChroma:

   The number of chroma bins per octave. It will determine how many channels are output per input channel.

:control ref:

   The frequency of reference in Hz for the tuning of the middle A (default: 440 Hz)

:control normalize:

   This flag enables the scaling of the output. It is off (0) by default. (1) will normalise each frame to sum to 1. (2) normalises each frame relative to the loudest chroma bin being 1.

:control minFreq:

   The lower frequency included in the analysis, in Hz.

:control maxFreq:

   The highest frequency included in the analysis, in Hz.

:control maxNumChroma:

   The maximum number of chroma bins. This sets the number of channels of the output stream, and therefore cannot be modulated.

:control windowSize:

   The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size, but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

