:digest: Sinusoidal Modelling and Resynthesis
:species: transformer
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation
:see-also: BufSines, Transients,HPSS
:description: Sinusoidal Modelling process on its audio input.
:discussion: 
   It implements a mix of algorithms taken from classic papers.

   	The algorithm will take an audio in, and will divide it in two parts:
   	   * a reconstruction of what it detects as sinusoidal;
   	   * a residual derived from the previous signal to allow null-summing

   	The whole process is based on the assumption that signal is made of pitched steady components that have a long-enough duration and are periodic enough to be perceived as such, that can be tracked, resynthesised and removed from the original, leaving behind what is considered as non-pitched, noisy, and/or transient. It first tracks the peaks, then checks if they are the continuation of a peak in previous spectral frames, by assigning them a track.

:process: The audio rate version of the object.
:output: An array of two audio streams: [0] is the harmonic part extracted, [1] is the rest. The latency between the input and the output is (( hopSize * minTrackLen) + windowSize) samples.


:control in:

   The input to be processed

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

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize. The -1 default value will default to the highest of windowSize and (bandwidth - 1) * 2.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

