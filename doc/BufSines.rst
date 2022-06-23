:digest: Buffer-Based Sinusoidal Modelling and Resynthesis
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulation
:see-also: Sines, BufHPSS, BufTransients
:description: Sinusoidal modelling on buffers
:discussion: 
   It implements a mix of algorithms taken from classic papers.

   The algorithm will take a buffer in, and will divide it in two parts:

     * a reconstruction of what it detects as sinusoidal
     * a residual derived from the previous buffer to allow null-summing

     The whole process is based on the assumption that signal is made of pitched steady components that have a long-enough duration and are periodic enough to be perceived as such, that can be tracked, resynthesised and removed from the original, leaving behind what is considered as non-pitched, noisy, and/or transient. It first tracks the peaks, then checks if they are the continuation of a peak in previous spectral frames, by assigning them a track.

:process: This is the method that calls for the sinusoidal estimation to be calculated on a given source buffer and to be resynthesised.
:output: Nothing, as the various destination buffers are declared in the function call.


:control source:

   The index of the buffer to use as the source material to be decomposed through the sinusoidal modelling process. The different channels of multichannel buffers will be processing sequentially.

:control startFrame:

   Where in the srcBuf should the process start, in sample.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel should be processed first.

:control numChans:

   For multichannel srcBuf, how many channels should be processed.

:control sines:

   The index of the buffer where the extracted sinusoidal component will be reconstructed.

:control residual:

   The index of the buffer where the residual of the sinusoidal component will be reconstructed.

:control bandwidth:

   The number of bins used to resynthesises a peak. It has an effect on CPU cost: the widest is more accurate but more computationally expensive. It is capped at (fftSize / 2) + 1.

:control detectionThreshold:

   The threshold in dB above which a magnitude peak is considered to be a sinusoidal component.

:control birthLowThreshold:

   The threshold in dB above which to consider a peak to start a sinusoidal component tracking, for the low end of the spectrum. It is interpolated across the spectrum until birthHighThreshold at half-Nyquist.

:control birthHighThreshold:

   The threshold in dB above which to consider a peak to start a sinusoidal component tracking, for the high end of the spectrum. It is interpolated across the spectrum until birthLowThreshold at DC.

:control minTrackLen:

   The minimum duration, in spectral frames, for a sinusoidal track to be accepted as a partial. It allows to remove bubbly pitchy artefactss, but is more CPU intensive and might reject quick pitch material.

:control trackingMethod:

   The algorithm used to track the sinusoidal continuity between spectral frames. 0 is the default, "Greedy", and 1 is a more expensive [^"Hungarian"]( Neri, J., and Depalle, P., "Fast Partial Tracking of Audio with Real-Time Capability through Linear Programming". Proceedings of DAFx-2018. ) one.

:control trackMagRange:

   The amplitude difference allowed for a track to diverge between frames, in dB.

:control trackFreqRange:

   The frequency difference allowed for a track to diverge between frames, in Hertz.

:control trackProb:

   The probability of the tracking algorithm to find a track.

:control windowSize:

   The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts.

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to the highest of windowSize and (bandwidth - 1) * 2.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

:control action:

   A Function to be evaluated once the offline process has finished and all Buffer's instance variables have been updated on the client side. The function will be passed [sines, residual] as an argument.

