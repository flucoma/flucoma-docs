:digest: Mel-Frequency Cepstral Coefficients as Spectral Descriptors in Real-Time
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufMFCC, Pitch, MelBands, Loudness, SpectralShape
:description: This class implements a classic spectral descriptor, the Mel-Frequency Cepstral Coefficients (MFCCs)
:discussion: 
   MFCC stands for Mel-Frequency Cepstral Coefficients ("cepstral" is pronounced like "kepstral"). This analysis is often used for timbral description and timbral comparison. The MFCC values are derived by first computing a mel-frequency spectrum, just as in :fluid-obj:``MelBands``. ``numCoeffs`` coefficients are then calculated by using that mel-frequency spectrum as input to the discrete cosine transform. This means that the shape of the mel-frequency spectrum is compared to a number of cosine wave shapes (different cosines shapes created from different different frequencies). Each MFCC value (i.e., "coefficient") represents how similar the mel-frequency spectrum is to one of these cosine shapes. 
   
   For an interactive explanation of this relationship, visit https://learn.flucoma.org/reference/mfcc.
   
   Other that the 0th coefficient (they start counting from zero), MFCCs are unchanged by differences in the overall energy of the spectrum (which relates to how we perceive loudness). This means that timbres that are the same will have the same MFCC values (other than MFCC 0) even if they're analysed at different loudnesses. MFCC 0 can still be useful if a measure of the overall energy in the spectrum is important for an analysis. If MFCC 0 is not desired, the parameter ``startCoeff`` can tell this object to return MFCCs starting at a coefficient other than 0 (most often 1). 
   
   .. only_in:: sc

      When ``numCoeffs`` is less than ``maxNumCoeffs`` the result will be zero-padded on the right so the control stream returned by this object is always ``maxNumCoeffs`` channels.

:process: The audio rate in, control rate out version of the object.
:output: 

   The process will return a stream of ``maxNumCoeffs`` MFCCs, which will be repeated if no change happens within the algorithm, i.e. when the hopSize is larger than the host vector size. When ``numCoeffs`` is less than ``maxNumCoeffs`` the result will be zero-padded on the right so the control stream returned by this object is always ``maxNumCoeffs`` channels. Latency is ``windowSize`` samples.


:control in:

   The audio to be processed.

:control numCoeffs:

   The number of cepstral coefficients to output. It is limited by the ``maxNumCoeffs`` parameter. When the number is smaller than the maximum, the output is zero-padded.

:control numBands:

   The number of mel-bands that will be perceptually equally distributed between ``minFreq`` and ``maxFreq`` to describe the spectral shape before the cepstral coefficients are computed.

:control startCoeff:

   The lowest index of the output cepstral coefficient, zero-counting. This can be useful to skip over the 0th coefficient (by indicating ``startCoeff`` = 1), because the 0th coefficient is representative of the overall energy in spectrum, while the rest of the coefficients are not affected by overall energy, only the mel-frequency spectral contour.

:control minFreq:

   The lower bound of the frequency band to use in analysis, in Hz.

:control maxFreq:

    The upper bound of the frequency band to use in analysis, in Hz.

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
