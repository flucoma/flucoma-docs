:digest: Non-Negative Double Singular Value Decomposition on a Buffer
:species: buffer-proc
:sc-categories: FluidManipulation
:sc-related: Classes/FluidBufNMF
:see-also: 
:description: Find Initial Bases and Activations for BufNMF
:discussion:

    BufNNDSVD uses Nonnegative Double Singular Value Decomposition which can help decide how to initialise BufNMF, by suggesting how many components to request (and what bases to seed) in order to account for a certain percentage of the variance in a buffer.
    
    See http://nimfa.biolab.si/nimfa.methods.seeding.nndsvd.html and https://www.sciencedirect.com/science/article/abs/pii/S0031320307004359 for more info.

:control source:

   The index of the buffer to analyse and suggest a number of components for.

:control bases:

   The index of the buffer where the bases will be written to. These will be the bases and are suggested seed for a BufNMF processes. The number of bases (i.e., channels) in this buffer when the process is complete is the number of components needed to cover the percentage of variance in the buffer.

:control activations:

   Must be set as an empty buffer (of any size), however no information is returned in this buffer.

:control minComponents:

   Minimum number of estimated components to return (minimum number of channels in ``bases`` buffer when the process is complete)

:control maxComponents:

   Maximum number of estimated components to return (maximum number of channels in ``bases`` buffer when the process is complete)

:control coverage:

   Fraction (0 to 1) of information preserved in the decomposition

:control method:

   The method used for the decomposition. Options are:
   
   :enum:
    
    :0: 
      **NMF-SVD:** Nonnegative Double Singular Value Decomposition
      
    :1: 
      **NNDSVDar:** Nonnegative Double Singular Value Decomposition where any elements that are zero are filled with a random value between 0 and the average * 0.01.
    
    :2: 
      **NNDSVDa:** Nonnegative Double Singular Value Decomposition where any elements that are zero are filled with the average value.
    
    :3: 
      **NNDSVD:** Nonnegative Double Singular Value Decomposition

:control windowSize:

   The window size. We need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will use the next power of 2 equal or above the highest of windowSize and (bandwidth - 1) * 2.
