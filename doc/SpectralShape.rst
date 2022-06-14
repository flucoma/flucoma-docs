:digest: Seven Spectral Shape Descriptors in Real-Time
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit, Classes/SpecCentroid, Classes/SpecFlatness, Classes/SpecCentroid, Classes/SpecPcile
:see-also: BufSpectralShape, Pitch, MelBands, Loudness, MFCC
:description: Seven of the  spectral shape descriptors, computed on a linear scale for both amplitude and frequency.
:discussion: 
   The descriptors are:
   
   * the four first statistical moments (`<https://en.wikipedia.org/wiki/Moment_(mathematics)>`_), more commonly known as:
        
     * the spectral centroid (1) in Hertz. This is the point that splits the spectrum in 2 halves of equal energy. It is the weighted average of the magnitude spectrum.
     * the spectral spread (2) in Hertz. This is the standard deviation of the spectrum envelop, or the average of the distance to the centroid.
     * the normalised skewness (3) as ratio. This indicates how tilted is the spectral curve in relation to the middle of the spectral frame, i.e. half of the Nyquist frequency. If it is below the frequency of the magnitude spectrum, it is positive.
     * the normalised kurtosis (4) as ratio. This indicates how focused is the spectral curve. If it is peaky, it is high.
    
   * the rolloff (5) in Hertz. This indicates the frequency under which 95% of the energy is included.
   * the flatness (6) in dB. This is the ratio of geometric mean of the magnitude, over the arithmetic mean of the magnitudes. It yields a very approximate measure on how noisy a signal is.
   * the crest (7) in dB. This is the ratio of the loudest magnitude over the RMS of the whole frame. A high number is an indication of a loud peak poking out from the overal spectral curve.

   The drawings in Peeters 2003 ( http://recherche.ircam.fr/anasyn/peeters/ARTICLES/Peeters_2003_cuidadoaudiofeatures.pdf ) are useful, as are the commented examples below. For the mathematically-inclined reader, the tutorials and code offered here  
   ( https://www.audiocontentanalysis.org/ ) are interesting to further the understanding. For examples of the impact of computing the moments in power magnitudes, and/or in exponential frequency scale, please refer to the helpfile.

   The process will return a multichannel control steam with the seven values, which will be repeated if no change happens within the algorithm, i.e. when the hopSize is larger than the signal vector size.

:process: The audio rate in, control rate out version of the object.
:output: A 7-channel KR signal with the seven spectral shape descriptors. The latency is windowSize.


:control in:

   The audio to be processed.

:control minFreq:

   The minimum frequency that the algorithm will consider for computing the spectral shape. Frequencies below will be ignored. The default of 0 goes down to DC when possible.

:control maxFreq:

   The maximum frequency that the algorithm will consider for computing the spectral shape. Frequencies above will be ignored. The default of -1 goes up to Nyquist.

:control rolloffPercent:

   This sets the percentage of the frame's energy that will be reported as the rolloff frequency. The default is 95%.

:control unit:

   The frequency unit for the spectral shapes to be computed upon, and outputted at. The default (0) is in Hertz and computes the moments on a linear spectrum. The alternative is in MIDI note numbers(1), which compute the moments on an exponential spectrum.

:control power:

   This flag sets the scaling of the magnitudes in the moment calculation. It uses either its amplitude (0, by default) or its power (1).

:control windowSize:

   The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

:control select:

   An array of ``symbols`` indicating which analyses to return. The options are ``centroid``, ``spread``, ``skewness``, ``kurtosis``, ``rolloff``, ``flatness``, and ``crest``. If nothing is specified, the object will return all the analyses. The analyses will always appear in their normal order, this argument just allows for a selection of them to be returned. Reordering the options in this argument will not reorder how the analyses are returned.
