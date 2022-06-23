:digest: A Perceptually Spread Spectral Contour Descriptor on a Buffer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Classes/FluidBufMFCC
:see-also: MelBands, BufPitch, BufLoudness, BufMFCC, BufSpectralShape, BufStats
:description: Magnitudes for a number of perceptually-evenly spaced bands.
:discussion: 

  :fluid-obj:`BufMelBands` returns a Mel-Frequency Spectrum containing the user-defined ``numBands``. The Mel-Frequency Spectrum is a histogram of FFT bins bundled according to their relationship to the Mel scale ( https://en.wikipedia.org/wiki/Mel_scale ) which represents frequency space logarithmically, mimicking how humans perceive pitch distance. The name "Mel" derives from the word "melody". The Hz-to-Mel conversion used by :fluid-obj:`BufMelBands` is ``mel = 1127.01048 * log(hz / 700.0 + 1.0)``. 
  
  This implementation allows selection of the range and number of bands dynamically. The ``numBands`` MelBands will be perceptually equally distributed between ``minFreq`` and ``maxFreq``.

  When using a high value for ``numBands``, you may end up with empty channels (filled with zeros) in the MelBands output. This is because there is not enough information in the FFT analysis to properly calculate values for every MelBand. Increasing the ``fftSize`` will ensure you have values for all the MelBands.
  
  Visit https://learn.flucoma.org/reference/melbands to learn more.

:process: This is the method that calls for the analysis to be calculated on a given source buffer.

:output: Nothing, as the ``features`` buffer is declared in the function call.

:control source:

   The index of the buffer to use as the source material to be analysed. The different channels of multichannel buffers will be processed sequentially.

:control startFrame:

   Where in the ``source`` to begin the analysis, in samples. The default is 0.

:control numFrames:

   How many frames should be analysed, in samples. The default of -1 indicates to analyse to the end of the buffer.

:control startChan:

   For a multichannel ``source``, which channel to begin analysis from. The default is 0.

:control numChans:

   For multichannel ``source``, how many channels should be processed, starting from ``startChan`` and counting up. The default of -1 indicates to analyse through the last channel in the ``source``.

:control features:

   The buffer to write the MelBands magnitudes into.

:control numBands:

   The number of bands that will be returned. This determines how many channels are in the ``features`` buffer (``numBands`` * ``numChans``). The default is 40.

:control minFreq:

   The lower bound of the frequency band to use in analysis, in Hz. The default is 20.

:control maxFreq:

   The upper bound of the frequency band to use in analysis, in Hz. The default is 20000.

:control normalize:

   This flag indicates whether to use normalized triangle filters, which account for the number of FFT magnitudes used to calculate the MelBands. When normalization is off (`normalize` = 0) the higher MelBands tend to be disproportionately large because they are summing more FFT magnitudes. The default is to have normalization on (`normalize` = 1).

:control scale:

    This flag sets the scaling of the output value. It is either linear (0, by default) or in dB (1).

:control windowSize:

   The window size. As spectral description relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

  The window hop size. As this analysis relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

  The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control padding:

   Controls the zero-padding added to either end of the source buffer or segment. Possible values are 0 (no padding), 1 (default, half the window size), or 2 (window size - hop size). Padding ensures that all input samples are completely analysed: with no padding, the first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function. Mode 1 has the effect of centering the first sample in the analysis window and ensuring that the very start and end of the segment are accounted for in the analysis. Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.

:control action:

   A Function to be evaluated once the offline process has finished and all Buffer's instance variables have been updated on the client side. The function will be passed [features] as an argument.
