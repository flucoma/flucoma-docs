:digest: Morph between sounds
:species: transformer
:sc-categories: FluidCorpusManipulation
:sc-related: Classes/FluidAudioTransport, Classes/FluidBufNMFCross
:see-also: 
:description: 
   Perform cross-synthesis using Nonnegative Matrix Factorization (NMF) and Optimal Transport (OT). NMF analyses of `source` and `target` sounds decompose their material in to a selectable number of components, which are in turn represented by their *bases* (spectrum) and *activations* (temporal pattern of each component).

   `FluidNMFMorph` provides the ability to interpolate between `source` and `target` spectra using a technique called Optimal Transport, that provides richer results than a simple linear interpolation between spectral shapes. The resulting sound is built up using a buffer of temporal activations, then resynthesised using a phase estimate.



:control source:

   A |buffer| with the spectral bases for the source sound.

:control target:

   A |buffer| with the spectral bases for the target sound.

:control activations:

   A |buffer| with the temporal activations for the target sound.

:control autoassign:

   If set to `1` the algorithm will attempt to optimally match which NMF basis components from source and target best match each other, and will use this mapping as its basis for interpolation.

:control interp:

   Set the relative contributions of `source` and `target` between 0 and 1.

:control windowSize:

   The analysis window size in samples. Needs to match that of the seeding NMF analyses

:control hopSize:

   The analysis hop size in samples. Needs to match that of the seeding NMF analyses

:control fftSize:

   The analysis FFT size in samples. Needs to match that of the seeding NMF analyses

:control maxFFTSize:

   The maximum FFT size to allocate memory for

