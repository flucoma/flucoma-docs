:digest: Non-Negative Double Singular Value Decomposition on a Buffer
:species: buffer-proc
:sc-categories: FluidManipulation
:sc-related: 
:see-also: BufNMF, NMFMatch, NMFFilter
:description: Find Initial Bases and Activations for BufNMF
:discussion:

    BufNMFSeed uses Nonnegative Double Singular Value Decomposition which can help decide how to initialise BufNMF, by suggesting how many components to request (and what bases and activations to seed) in order to account for a certain percentage of the variance in a buffer. In general, using this process to seed a BufNMF decomposition should substantially increase the speed with which BufNMF converges and avoid especially poor local minima.
    
    See http://nimfa.biolab.si/nimfa.methods.seeding.nndsvd.html and https://www.sciencedirect.com/science/article/abs/pii/S0031320307004359 for more info.

:control source:

   The |buffer| to analyse and suggest a number of components for.

:control bases:

   The |buffer| where the bases will be written to. These bases are suggested seeds for a BufNMF process. The number of bases (i.e., channels) in this buffer when the process is complete is the number of components needed to cover the requested percentage of variance in the buffer.

:control activations:

   The |buffer| where the activations will be written to. These bases are suggested seeds for a BufNMF process. The number of bases (i.e., channels) in this buffer when the process is complete is the number of components needed to cover the requested percentage of variance in the buffer.

:control minComponents:

   Minimum number of estimated components to return (minimum number of channels in ``bases`` |buffer| when the process is complete)

:control maxComponents:

   Maximum number of estimated components to return (maximum number of channels in ``bases`` |buffer| when the process is complete)

:control coverage:

   Fraction (0 to 1) of information preserved in the decomposition

:control method:

   The method used to account for certain values before processing. Zeros in the matrix will remain zero when "updated" because the updates are being multiplied by a scalar, therefore it may be useful to change any zeros to something else before the process. Options are:
   
   :enum:
    
    :0: 
      **NMF-SVD** Nonnegative Double Singular Value Decomposition where any negative values are first converted to their absolute value. This is likely to be quicker than the other options, but less rigorous.
      
    :1: 
      **NNDSVDar** Nonnegative Double Singular Value Decomposition where any elements that are zero are first filled with a random value between 0 and the ``average * 0.01`` (essentially small random values). This may be slightly faster but slightly less accurate than other options.
    
    :2: 
      **NNDSVDa** Nonnegative Double Singular Value Decomposition where any elements that are zero are first filled with the average value.
    
    :3: 
      **NNDSVD** Nonnegative Double Singular Value Decomposition where values are not changed according to any criteria. This promotes sparse results from the subsequent NMF (because, with multiplicative updates, zeros remain zeros). This may or may not be desirable (not least because sparsity implies the need for more components, but also the specific domain might imply that reasonable decomposition just isn't going to be sparse). 

:control seed:

   The seed provided to the pseudo-random number generator used within the algorithm. This allows for repeatable results from these generators; the same seed will consistently produce the same result. The default is -1, which requests a 'real' random, unpredictable seed.

:control windowSize:

   The window size. We need to decide what precision we give it spectrally and temporally. For more information visit https://learn.flucoma.org/learn/fourier-transform/

:control hopSize:

   The window hop size. It can be any size, but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

  The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will use the next power of 2 equal or above the highest of windowSize and (bandwidth - 1) * 2.
