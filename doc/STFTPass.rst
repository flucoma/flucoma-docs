:digest: Realtime FFT/IFFT return trip.
:species: transformer
:sc-categories: UGens>Algebraic, Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulation,Classes/UnaryOpFunction
:see-also: 
:description: This class implements a sanity test for the FluCoMa Realtime Client FFT/IFFT Wrapper.
:discussion: 
:process: The audio rate version of the object.
:output: Same as input, delayed by the windowSize.


:control in:

   The input to be passed-through

:control windowSize:

   The size of the buffered window to be analysed, in samples. It will add that much latency to the signal.

:control hopSize:

   How much the buffered window moves forward, in samples. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   How large will the FFT be, zero-padding the buffer to the right size, which should be bigger than the windowSize argument, bigger than 4 samples, and should be a power of 2. This is a way to oversample the FFT for extra precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

