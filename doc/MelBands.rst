:digest: A Perceptually Spread Spectral Contour Descriptor
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit, Classes/FluidMFCC
:see-also: BufMelBands, Pitch, Loudness, MFCC, SpectralShape
:description: Magnitudes for a number of perceptually-evenly spaced bands.
:discussion: 

   :fluid-obj:`MelBands` returns a Mel-Frequency Spectrum comprised of the user-defined ``numBands``. The Mel-Frequency Spectrum is a histogram of FFT bins bundled according their relationship to the Mel scale (https://en.wikipedia.org/wiki/Mel_scale) which represents frequency space logarithmically, mimicking how humans perceive pitch distance. The name "Mel" derives from the word "melody". The Hz-to-Mel conversion used by :fluid-obj:`MelBands` is ``mel = 1127.01048 * log(hz / 700.0 + 1.0)``. This implementation allows to select the range and number of bands dynamically.

   When using a high value for ``numBands``, you may end up with empty channels (filled with zeros) in the MelBands output. This is because there is not enough information in the FFT analysis to properly calculate values for every MelBand. Increasing the ``fftSize`` will ensure you have values for all the MelBands.
   
:process: The audio rate in, control rate out version of the object.
:output: A KR signal of ``maxNumBands channels``, giving the measured magnitudes for each band. The latency is windowSize.

:control in:

   The audio to be processed.

:control numBands:

   The number of bands that will be perceptually equally distributed between ``minFreq`` and ``maxFreq``. It is limited by the maxNumBands parameter. When the number is smaller than the maximum, the output is zero-padded.

:control minFreq:

   The lower bound of the frequency band to use in analysis, in Hz. The default is 20.

:control maxFreq:

   The upper bound of the frequency band to use in analysis, in Hz. The default is 20000.

:control maxNumBands:

   The maximum number of Mel bands that can be modelled. This sets the number of channels of the output, and therefore cannot be modulated. The default is 120.

:control normalize:

   This flag causes the output to be scaled, preserving the energy of the window. It is on (1) by default.

:control scale:

   This flag sets the scaling of the output value. It is either linear (0, by default) or in dB (1).

:control windowSize:

   The window size. As spectral description relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As spectral description relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large the FFT can be, by allocating memory at instantiation time. This cannot be modulated.
