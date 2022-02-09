:digest: Resynthesise a target sound based on a source sound
:species: buffer-proc
:sc-categories: FluidManipulation
:sc-related: Classes/FluidBufNMF, Classes/FluidNMFMatch, Classes/FluidNMFFilter
:see-also: 
:description: Reconstructs the sound in the target buffer using components learned from the source buffer using an NMF decomposition
:discussion: 
   The process works by attempting to reconstruct compoentns of the `target` sound using the timbre of the `source` sound, learned through a Nonnegative Matrix Factorisation. The result is a hybrid whose character depends on how well the target can be represnted by the source's spectral frames.

   In contrast to :fluid-obj:`BufNMF`, the size and content of the bases dictionary are fixed in this application to be the spectrogram of the `source`. Each spectral frame of `source` is a template: be aware that NMF is O(N^2) in the number of templates, so longer `source` buffers will take dramatically longer to process.

   See Driedger, J., Prätzlich, T., & Müller, M. (2015). Let it Bee-Towards NMF-Inspired Audio Mosaicing. ISMIR, 350–356. http://ismir2015.uma.es/articles/13_Paper.pdf



:control source:

   A buffer whose content will supply the spectral bases used in the hybrid

:control target:

   A buffer whose content will supply the temporal activations used in the hybrid

:control output:

   A buffer to contain the new sound

:control timeSparsity:

   Control the repetition of source templates in the reconstruction by specifying a number of frames within which a template should not be re-used. Units are spectral frames.

:control polyphony:

   Control the spectral density of the output sound by restricting the number of simultaneous templates that can be used. Units are spectral bins.

:control continuity:

   Promote the use of N successive source frames, giving greater continuity in the result. This can not be bigger than the sizes of the input buffers, but useful values tend to be much lower (in the tens).

:control iterations:

   How many iterations of NMF to run

:control windowSize:

   The analysis window size in samples

:control hopSize:

   The analysus hop size in samples (default winSize / 2)

:control fftSize:

   The analsyis FFT size in samples (default = winSize)

