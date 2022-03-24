:digest: Mel-Frequency Cepstral Coefficients as Spectral Descriptors on a Buffer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit, Guides/FluidBufMultiThreading, Classes/FluidBufMelBands
:see-also: 
:description: 
    
  MFCC stands for Mel-Frequency Cepstral Coefficients ("cepstral" is pronounced like "kepstral"). This analysis is often used for timbral description and timbral comparison. It compresses the overall spectrum into a smaller number of coefficients that, when taken together, describe the general contour the the spectrum.

  The MFCC values are derived by first computing a mel-frequency spectrum, just as in :fluid-obj:`MelBands`. ``numCoeffs`` coefficients are then calculated by using that mel-frequency spectrum as input to the discrete cosine transform. This means that the shape of the mel-frequency spectrum is compared to a number of cosine wave shapes (different cosines shapes created from different different frequencies). Each MFCC value (i.e., "coefficient") represents how similar the mel-frequency spectrum is to one of these cosine shapes. 

  Other that the 0th coefficient, MFCCs are unchanged by differences in the overall energy of the spectrum (which relates to how we perceive loudness). This means that timbres with similar spectral contours, but different volumes, will still have similar MFCC values, other than MFCC 0. To remove any indication of loudness but keep the information about timbre, we can ignore MFCC 0 by setting the parameter ``startCoeff`` to 1.

   For more information visit https://learn.flucoma.org/reference/mfcc/.
   
   For an interactive explanation of this relationship, visit https://learn.flucoma.org/reference/mfcc/explain.
   
:control source:

   The index of the buffer to use as the source material to be analysed. The different channels of multichannel buffers will be processing sequentially.

:control startFrame:

   Where in the ``srcBuf`` the analysis should start, in samples. The default is 0.

:control numFrames:

   How many frames should be analysed. The default of -1 indicates to analyse to the end of the buffer.

:control startChan:

   For a multichannel ``srcBuf``, which channel should be processed first. The default is 0.

:control numChans:

   For a multichannel ``srcBuf``, how many channels should be processed. The default of -1 indicates to analyse through the last channel.

:control features:

   The destination buffer to write the MFCC analysis into.

:control numCoeffs:

   The number of cepstral coefficients to return. The default is 13.

:control numBands:

   The number of bands that will be perceptually equally distributed between ``minFreq`` and ``maxFreq``. The default is 40.

:control startCoeff:

   The lowest index of the output cepstral coefficients to return, zero-counting. This can be useful to skip over the 0th coefficient (by indicating ``startCoeff`` = 1), because the 0th coefficient is representative of the overall energy in spectrum, while the rest of the coefficients are not affected by overall energy, only the mel-frequency spectral contour. The default is 0.

:control minFreq:

   The lower bound of the frequency band to use in analysis, in Hz. The default is 20.

:control maxFreq:

   The upper bound of the frequency band to use in analysis, in Hz. The default is 20000.

:control windowSize:

   The window size. As MFCC computation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty. The default is 1024.

:control hopSize:

   The window hop size. As MFCC computation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will use the next power of 2 equal or above the windowSize.

:control padding:

   Controls the zero-padding added to either end of the source buffer or segment. Possible values are 0 (no padding), 1 (default, half the window size), or 2 (window size - hop size). Padding ensures that all input samples are completely analysed: with no padding, the first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function. Mode 1 has the effect of centring the first sample in the analysis window and ensuring that the very start and end of the segment are accounted for in the analysis. Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.
