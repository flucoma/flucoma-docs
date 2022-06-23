:digest: A histogram of pitch classes on a Buffer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Classes/FluidBufMFCC
:see-also: Chroma, BufPitch, BufLoudness, BufMFCC, BufSpectralShape, BufStats
:description: This class computes a histogram of the energy contained for each pitch class across the analysis frequency range.
:discussion: 
   Also known as a chromagram, this typically allows you to get a contour of how much each semitone is represented in the spectrum over time. The number of chroma bins (and, thus, pitch classes) and the central reference frequency can be adjusted.

   The process will return a single multichannel buffer of STRONG::numChroma:: per input channel. Each frame represents a value, which is every hopSize.

:process: This is the method that calls for the chromagram to be calculated on a given source buffer.
:output: Nothing, as the destination buffer is declared in the function call.


:control source:

   The index of the buffer to use as the source material to be analysed. The different channels of multichannel buffers will be processed sequentially.

:control startFrame:

   Where in the srcBuf should the process start, in sample.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel should be processed first.

:control numChans:

   For multichannel srcBuf, how many channels should be processed.

:control features:

   The destination buffer for the STRONG::numChroma:: to be written to.

:control numChroma:

   The number of chroma bins per octave. It will determine how many channels are output per input channel.

:control ref:

   The frequency of reference in Hz for the tuning of the middle A (default: 440 Hz)

:control normalize:

   This flag enables the scaling of the output. It is off (0) by default. (1) will normalise each frame to sum to 1. (2) normalises each frame relative to the loudest chroma bin being 1.

:control minFreq:

   The lower frequency included in the analysis, in Hz.

:control maxFreq:

   The highest frequency included in the analysis, in Hz.

:control windowSize:

   The window size. As chroma description relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As chroma description relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts.

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision.

:control padding:

   Controls the zero-padding added to either end of the source buffer or segment. Possible values are 0 (no padding), 1 (default, half the window size), or 2 (window size - hop size). Padding ensures that all input samples are completely analysed: with no padding, the first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function. Mode 1 has the effect of centering the first sample in the analysis window and ensuring that the very start and end of the segment are accounted for in the analysis. Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

