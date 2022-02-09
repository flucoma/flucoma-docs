:digest: Mel-Frequency Cepstral Coefficients as Spectral Descriptors in Real-Time
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufMFCC, Pitch, MelBands, Loudness, SpectralShape
:description: This class implements a classic spectral descriptor, the Mel-Frequency Cepstral Coefficients (MFCCs)
:discussion: 
   See https://en.wikipedia.org/wiki/Mel-frequency_cepstrum. The input is first decomposed into perceptually spaced bands (the number of bands specified by numBands), just as in the MelBands object. It is then analysed in numCoefs number of cepstral coefficients. It has the avantage to be amplitude invarient, except for the first coefficient.

   The process will return a multichannel control steam of maxNumCoeffs, which will be repeated if no change happens within the algorithm, i.e. when the hopSize is larger than the host vector size.

:process: The audio rate in, control rate out version of the object.
:output: A  KR signal of STRONG::maxNumCoefs:: channels. The latency is windowSize.


:control in:

   The audio to be processed.

:control numCoeffs:

   The number of cepstral coefficients to be outputed. It is limited by the maxNumCoefs parameter. When the number is smaller than the maximum, the output is zero-padded.

:control numBands:

   The number of bands that will be perceptually equally distributed between minFreq and maxFreq to describe the spectral shape before it is converted to cepstral coefficients.

:control startCoeff:

   The lowest index of the output cepstral coefficient, zero-counting.

:control minFreq:

   The lower boundary of the lowest band of the model, in Hz.

:control maxFreq:

   The highest boundary of the highest band of the model, in Hz.

:control maxNumCoeffs:

   The maximum number of cepstral coefficients that can be computed. This sets the number of channels of the output, and therefore cannot be modulated.

:control windowSize:

   The window size. As MFCC computation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As MFCC computation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

