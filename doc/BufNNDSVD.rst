:digest: Non-Negative Double Singular Value Decomposition on a Buffer
:species: buffer-proc
:sc-categories: FluidManipulation
:sc-related: Classes/FluidBufNMF
:see-also: 
:description: 
   Find Initial Bases and Activations for FluidBufNMF via Non-Negative Double Singular Value Decomposition .

   See http://nimfa.biolab.si/nimfa.methods.seeding.nndsvd.html



:control source:

   The index of the buffer to use as the source material to be decomposed through the NMF process. The different channels of multichannel buffers will be processing sequentially.

:control bases:

   The index of the buffer where the different bases will be written to and/or read from: the behaviour is set in the following argument.

:control activations:

   The index of the buffer where the different activations will be written to and/or read from: the behaviour is set in the following argument.

:control minComponents:

   Minimum number of estimated components

:control maxComponents:

   Maximum number of estimated components

:control coverage:

   Fraction (0 to 1) of information preserved in the decomposition

:control method:

   The method used for the decomposition. Options are:

:control windowSize:

   The window size. As spectral differencing relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will use the next power of 2 equal or above the highest of windowSize and (bandwidth - 1) * 2.

