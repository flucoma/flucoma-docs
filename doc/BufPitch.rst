:digest: Pitch Descriptor
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Classes/SpecCentroid, Classes/SpecFlatness, Classes/SpecCentroid, Classes/SpecPcile
:see-also: Pitch, BufLoudness, BufMelBands, BufMFCC, BufSpectralShape, BufStats
:max-seealso: fzero~, retune~
:description: Three popular pitch descriptors, all of which compute frequency and the confidence that a pitch is present.
:discussion: 

  :fluid-obj:`Pitch` returns both ``pitch`` and ``confidence`` values. When no pitch can be detected, a pitch of 0 Hz is returned (or -999.0 when the unit is in MIDI note mode).

  For information about the pitch descriptor algorithms, see the ``algorithm`` parameter below.

  The "confidence" output is a value between 0 and 1 indicating how confident the algorithm is in the pitch that it is reporting. In effect this can be an estimation of how "noisy" (closer to 0) or "harmonic" (closer to 1) the spectrum is. The confidence may also be low when a signal contains polyphony, as the algorithms are not intended for multiple pitch streams.

  The ``unit`` argument indicates whether the pitch output should be in hertz (indicated by 0) or MIDI note numbers (indicated by 1). MIDI note numbers may be useful, not only because of their direct relationship to MIDI-based synthesis systems, but also because of the logarithmic relationship to hertz, making them perceptually evenly-spaced units (1 MIDI note = 1 semitone).

  For more information visit https://learn.flucoma.org/reference/pitch/.

:process: This is the method that calls for the descriptor to be calculated on a given source buffer.

:output: Nothing, as the destination buffer is declared in the function call.

:control source:

   The index of the buffer to use as the source material to be pitch-tracked. The different channels of multichannel buffers will be processed sequentially.

:control select:

   An array of ``symbols`` indicating which analyses to return. The options are ``pitch`` and ``confidence``. If nothing is specified, the object will return all the analyses. The analyses will always appear in their normal order, this argument just allows for a selection of them to be returned. Reordering the options in this argument will not reorder how the analyses are returned.

:control startFrame:

   Where in ``source`` to start the analysis, in samples. The default is 0.

:control numFrames:

   How many samples to analyse. The default of -1 indicates to analyse through to the end of the buffer.

:control startChan:

   For multichannel ``source``, from which channel to begin analysing. The default is 0.

:control numChans:

   For multichannel ``source``, how many channels should be processed. The default of -1 indicates to analyse through the last channel in the buffer.

:control features:

   The destination buffer for the descriptors.

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

   The minimum fundamental frequency that the algorithm withh search for. This sets the lowest value that will be generated. The default is 20.

:control maxFreq:

   The maximum fundamental frequency that the algorithm withh search for. This sets the highest value that will be generated. The default is 10000.

:control unit:

   The unit of the estimated value. The default of 0 is in Hz. A value of 1 will convert to MIDI note values.

:control windowSize:

   The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts.

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision.

:control padding:

   Controls the zero-padding added to either end of the source buffer or segment. Possible values are 0 (no padding), 1 (default, half the window size), or 2 (window size - hop size). Padding ensures that all input samples are completely analysed: with no padding, the first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function. Mode 1 has the effect of centering the first sample in the analysis window and ensuring that the very start and end of the segment are accounted for in the analysis. Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

:control action:

   A Function to be evaluated once the offline process has finished and all Buffer's instance variables have been updated on the client side. The function will be passed [features] as an argument.
