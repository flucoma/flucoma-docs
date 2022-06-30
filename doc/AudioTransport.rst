:digest: Interpolate between sounds
:species: transformer[2]
:sc-categories: FluidManipulation
:sc-related: Classes/FluidBufAudioTransport
:see-also: NMFMorph, BufNMFCross
:description: 
   Interpolates between the spectra of two sounds using optimal transport.

:discussion:
   Interpolates between the spectra of two sounds using the optimal transport algorithm. This enables morphing and hybridisation of the perceptual qualities of each source linearly.
   See Henderson and Solomon (2019) AUDIO TRANSPORT: A GENERALIZED PORTAMENTO VIA OPTIMAL TRANSPORT, DaFx

   https://arxiv.org/abs/1906.06763

:control in2:

   Source B

:control interpolation:

   The amount to interpolate between A and B (0-1, 0 = A, 1 = B)

:control windowSize:

   The window size in samples. As HPSS relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size in samples. As HPSS relies on spectral frames, we need to move the window forward. It can be any size, but low overlap may create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long; at least the size of the window; and a power of 2. Making it larger than the window size provides interpolation in frequency. The -1 default value will use the next power of 2 equal or above the windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

