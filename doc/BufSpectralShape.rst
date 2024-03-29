:digest: Seven Spectral Shape Descriptors on a Buffer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Classes/SpecCentroid, Classes/SpecFlatness, Classes/SpecPcile
:see-also: SpectralShape, BufPitch, BufMelBands, BufMFCC, BufLoudness, BufStats
:description: Seven of the spectral shape descriptors, computed on a linear scale for both amplitude and frequency.
:discussion: 
   The descriptors are:
   
   * the four first statistical moments (https://en.wikipedia.org/wiki/Moment_(mathematics) ):
  
     * the spectral centroid (1) in Hertz. This is the point that splits the spectrum in 2 halves of equal energy. It is the weighted average of the magnitude spectrum.
     * the spectral spread (2) in Hertz. This is the standard deviation of the spectrum envelope, or the average of the distance to the centroid.
     * the normalised skewness (3) as ratio. This indicates how tilted is the spectral curve in relation to the middle of the spectral frame, i.e. half of the Nyquist frequency. If it is below the frequency of the magnitude spectrum, it is positive.
     * the normalised kurtosis (4) as ratio. This indicates how focused is the spectral curve. If it is peaky, it is high.
  
   * the rolloff (5) in Hertz. This indicates the frequency under which 95% of the energy is included.
   * the flatness (6) in dB. This is the ratio of geometric mean of the magnitude, over the arithmetic mean of the magnitudes. It yields a very approximate measure on how noisy a signal is.
   * the crest (7) in dB. This is the ratio of the loudest magnitude over the RMS of the whole frame. A high number is an indication of a loud peak poking out from the overal spectral curve.

   The drawings in Peeters 2003 ( http://recherche.ircam.fr/anasyn/peeters/ARTICLES/Peeters_2003_cuidadoaudiofeatures.pdf ) are useful, as are the commented examples below. For the mathematically-inclined reader, the tutorials and code offered here ( https://www.audiocontentanalysis.org/ ) are interesting to further the understanding. For examples of the impact of computing the moments in power magnitudes, and/or in exponential frequency scale, please refer to the :fluid-obj:`SpectralShape` helpfile.

   The process will return a multichannel buffer with the seven channels per input channel, each containing the 7 shapes. Each sample represents a value, which is every hopSize.

:process: This is the method that calls for the spectral shape descriptors to be calculated on a given source buffer.
:output: Nothing, as the destination buffer is declared in the function call.


:control source:

   The buffer to use as the source material to be described through the various descriptors. The different channels of multichannel buffers will be processed sequentially.

:control startFrame:

   Where in the srcBuf should the process start, in samples.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel should be processed first.

:control numChans:

   For multichannel srcBuf, how many channels should be processed.

:control features:

   The destination buffer for the 7 spectral features describing the spectral shape.

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

   The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally. For more information visit https://learn.flucoma.org/learn/fourier-transform/

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size, but low overlap will create audible artefacts.

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision.

:control padding:

   Controls the zero-padding added to either end of the source buffer or segment. Padding ensures all values are analysed. Possible values are:
   
   :enum:

      :0:
         No padding - The first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function.
   
      :1: 
         Half the window size - The first sample is centred in the analysis window ensuring that the start and end of the segment are accounted for in the analysis.
   
      :2: 
         Window size minus the hop size - Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

:control select:

   An array of ``symbols`` indicating which analyses to return. The options are ``centroid``, ``spread``, ``skewness``, ``kurtosis``, ``rolloff``, ``flatness``, and ``crest``. If nothing is specified, the object will return all the analyses. The analyses will always appear in their normal order, this argument just allows for a selection of them to be returned. Reordering the options in this argument will not reorder how the analyses are returned.