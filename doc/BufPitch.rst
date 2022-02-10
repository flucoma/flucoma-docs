:digest: A Selection of Pitch Descriptors on a Buffer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit, Classes/SpecCentroid, Classes/SpecFlatness, Classes/SpecCentroid, Classes/SpecPcile
:see-also: Pitch, BufLoudness, BufMelBands, BufMFCC, BufSpectralShape, BufStats
:description: Implements three pitch descriptors, computed as frequency and the confidence in its value.
:discussion: The process will return a multichannel buffer with two channels per input channel, one for pitch and one for the pitch tracking confidence. A pitch of 0 Hz is yield (or -999.0 when the unit is in MIDI note) when the algorithm cannot find a fundamental at all. Each sample represents a value, which is every hopSize. Its sampling rate is sourceSR / hopSize.
:process: This is the method that calls for the pitch descriptor to be calculated on a given source buffer.
:output: Nothing, as the destination buffer is declared in the function call.


:control source:

   The index of the buffer to use as the source material to be pitch-tracked. The different channels of multichannel buffers will be processing sequentially.

:control startFrame:

   Where in the srcBuf should the process start, in sample.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel should be processed first.

:control numChans:

   For multichannel srcBuf, how many channel should be processed.

:control features:

   The destination buffer for the pitch descriptors.

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

   The minimum frequency that the algorithm will search for an estimated fundamental. This sets the lowest value that will be generated.

:control maxFreq:

   The maximum frequency that the algorithm will search for an estimated fundamental. This sets the highest value that will be generated.

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
