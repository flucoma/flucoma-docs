:digest: Morph between sounds
:species: transformer[0]
:sc-categories: FluidCorpusManipulation
:sc-related: 
:see-also: BufNMF, BufNMFCross, AudioTransport, BufAudioTransport 
:description: 
   Perform cross-synthesis using Nonnegative Matrix Factorization (NMF) and Optimal Transport (OT). 

:discussion:
   The algorithm uses NMF analyses of the ``source`` and ``target`` sounds. It decomposes their material in to a selectable number of components, which are in turn represented by their *bases* (spectrum) and *activations* (temporal pattern of each component). ``NMFMorph`` provides the ability to interpolate between ``source`` and ``target`` bases using a technique called Optimal Transport, that provides richer results than a simple linear interpolation between spectral shapes. The resulting sound is built up using a buffer of temporal activations, then resynthesised using a phase estimate.

:control source:

   A |buffer| with the spectral bases for the source sound (must be the same number of spectral bases as ``target``).

:control target:

   A |buffer| with the spectral bases for the target sound (must be the same number of spectral bases as ``source``).

:control activations:

   A |buffer| with the temporal activations for the target sound.

:control autoassign:

   If set to ``1`` the algorithm will attempt to optimally match which NMF basis components from source and target best match each other, and will use this mapping as its basis for interpolation.

:control interpolation:

   Set the relative contributions of ``source`` and ``target`` between 0 and 1.

:control windowSize:

   The analysis window size in samples. Needs to match that of the seeding NMF analyses

:control hopSize:

   The analysis hop size in samples. Needs to match that of the seeding NMF analyses

:control fftSize:

   The analysis FFT size in samples. Needs to match that of the seeding NMF analyses

:control maxFFTSize:

   The maximum FFT size to allocate memory for
