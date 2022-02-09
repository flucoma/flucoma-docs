:digest: Interpolate between buffers
:species: buffer-proc
:sc-categories: FluidManipulation
:sc-related: Classes/FluidAudioTransport
:see-also: 
:description: 
   Interpolates between the spectra of two sounds using the Optimal Transport algorithm

   See Henderson and Solomonm (2019) AUDIO TRANSPORT: A GENERALIZED PORTAMENTO VIA OPTIMAL TRANSPORT, DaFx



:control sourceA:

   The first source buffer

:control startFrameA:

   offset into the first source buffer (samples)

:control numFramesA:

   number of samples to use from first source buffer

:control startChanA:

   starting channel of first source buffer

:control numChansA:

   number of channels to process in first source buffer

:control sourceB:

   the second source buffer

:control startFrameB:

   offset into the second source buffer (samples)

:control numFramesB:

   number of samples to process from second buffer

:control startChanB:

   starting channel for second buffer

:control numChansB:

   number of channels to process in second buffer

:control destination:

   buffer for interpolated audio

:control interpolation:

   The amount to interpolate between A and B (0-1, 0 = A, 1 = B)

:control windowSize:

   The window size. As spectral differencing relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will use the next power of 2 equal or above the highest of windowSize and (bandwidth - 1) * 2.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

