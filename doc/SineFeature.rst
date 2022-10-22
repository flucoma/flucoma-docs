:digest: Sinusoidal Peak Tracking
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Classes/SinOsc
:see-also: BufSineFeature, Sines
:description: Interpolated Sinusoidal Peak Tracking on the Spectrum.
:discussion: 
   This process is tracking peaks in the spectrum, then estimating an interpolated frequency and amplitude of that peak in relation to its spectral context. It is the first part of the process used by :fluid-obj:`Sines`.

:process: The audio rate version of the object.
:output: An array of two control streams: [0] is the interpolated frequency of the peaks extracted in Hz, [1] is their respective magnitudes in dB. The latency between the input and the output is windowSize samples.


:control in:

   The input to be processed

:control numPeaks:

      The number of peaks to search report back. It is capped at (fftSize / 2) + 1.

:control detectionThreshold:

   The threshold in dB above which a magnitude peak is considered to be a sinusoidal component.

:control sortBy:

   How the reported peaks are to be ordered. By default (0), it is by frequencies (lowest first), and the alternative (1) is by magnitude (loudest first).

:control windowSize:

   The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally. For more information visit https://learn.flucoma.org/learn/fourier-transform/

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size, but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize. The -1 default value will default to the highest of windowSize and (bandwidth - 1) * 2.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

:control maxNumPeaks:

  Up to how many peaks can be reported, by allocating memory at instantiation time. This cannot be modulated.
