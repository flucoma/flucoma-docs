:digest: Resynthesise a target sound based on a source sound
:species: buffer-proc
:sc-categories: FluidManipulation
:sc-related: Classes/FluidBufNMF, Classes/FluidNMFMatch, Classes/FluidNMFFilter
:see-also: 
:description: Uses NMF decomposition to reconstruct a target sound using components learned from a source sound 
:discussion: 

   The process works by attempting to reconstruct components of the ``target`` sound using the timbre (i.e., spectra) of the ``source`` sound, learned through a Non-negative Matrix Factorisation. The result is a hybrid whose character depends on how well the target can be represented by the source's spectral frames.

   In contrast to :fluid-obj:`BufNMF`, each spectral frame of ``source`` is a spectral template. Be aware that NMF is O(N^2) in the number of templates, so longer ``source`` buffers will take dramatically longer to process.

   See Driedger, J., Prätzlich, T., & Müller, M. (2015). Let it Bee-Towards NMF-Inspired Audio Mosaicing. ISMIR, 350–356. http://ismir2015.uma.es/articles/13_Paper.pdf
   
:control source:

   A buffer whose content will supply the spectral bases used in the hybrid. The result will use the spectral frames from this buffer.

:control target:

   A buffer whose content will supply the temporal activations used in the hybrid. The process aims to "sound like" this buffer using spectra from ``source``.

:control output:

   A buffer to write the new sound to.

:control timeSparsity:

   Control the repetition of source templates in the reconstruction by specifying a number of frames within which a template should not be re-used. Units are spectral frames. The default is 7.

:control polyphony:

   Control the spectral density of the output sound by restricting the number of simultaneous templates that can be used. Units are spectral bins. The default is 10.

:control continuity:

   Promote the use of N successive source frames, giving greater continuity in the result. This can not be bigger than the sizes of the ``source`` buffer, but useful values tend to be much lower (in the tens). The default is 7.

:control iterations:

   How many iterations of NMF to run. The default is 50.

:control windowSize:

   The analysis window size in samples. The default is 1024.

:control hopSize:

   The analysis hop size in samples. The default of -1 indicates half the ``windowSize``

:control fftSize:

   The analsyis FFT size in samples The default of -1 indicates ``fftSize`` = ``windowSize``
