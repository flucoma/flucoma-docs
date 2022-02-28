:digest: A Perceptually Spread Spectral Contour Descriptor in Real-Time
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit, Classes/FluidMFCC
:see-also: BufMelBands, Pitch, Loudness, MFCC, SpectralShape
:description: Amplitude for a number of equally spread perceptual bands.
:discussion: 
   The spread is based on the Mel scale (https://en.wikipedia.org/wiki/Mel_scale) which was one of the first attempts to mimic pitch perception scientifically. This implementation allows to select the range and number of bands dynamically.

   The process will return a multichannel control steam of size maxNumBands, which will be repeated if no change happens within the algorithm, i.e. when the hopSize is larger than the signal vector size.

   When using a high value for ``numBands``, you may end up with empty channels (filled with zeros) in the MelBands output. This is because there is not enough information in the FFT analysis to properly calculate values for every MelBand. Increasing the ``fftSize`` will ensure you have values for all the MelBands.
   
:process: The audio rate in, control rate out version of the object.
:output: A  KR signal of maxNumBands channels, giving the measure amplitudes for each band. The latency is windowSize.


:control in:

   The audio to be processed.

:control numBands:

   The number of bands that will be perceptually equally distributed between minFreq and maxFreq. It is limited by the maxNumBands parameter. When the number is smaller than the maximum, the output is zero-padded.

:control minFreq:

   The lower boundary of the lowest band of the model, in Hz.

:control maxFreq:

   The highest boundary of the highest band of the model, in Hz.

:control maxNumBands:

   The maximum number of Mel bands that can be modelled. This sets the number of channels of the output, and therefore cannot be modulated.

:control normalize:

   This flag enables the scaling of the output to preserve the energy of the window. It is on (1) by default.

:control scale:

   This flag sets the scaling of the output value. It is either linear (0, by default) or in dB (1).

:control windowSize:

   The window size. As spectral description relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As spectral description relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

