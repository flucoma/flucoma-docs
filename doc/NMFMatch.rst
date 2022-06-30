:digest: Realtime Non-Negative Matrix Factorisation with Fixed Bases
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation
:see-also: NMFFilter, BufNMF
:description: Matches an incoming audio signal against a set of spectral templates
:discussion: 
   This uses a slimmed-down version of Nonnegative Matrix Factorisation (NMF, Lee, Daniel D., and H. Sebastian Seung. 1999. ‘Learning the Parts of Objects by Non-Negative Matrix Factorization’. Nature 401 (6755): 788–91. https://doi.org/10.1038/44565.)

   It outputs at kr the degree of detected match for each template (the activation amount, in NMF-terms). The spectral templates are presumed to have been produced by the offline NMF process (BufNMF), and must be the correct size with respect to the FFT settings being used (FFT size / 2 + 1 frames long). The components of the decomposition are determined by the number of channels in the supplied buffer of templates, up to a maximum set by the maxComponents parameter.

   NMF has been a popular technique in signal processing research for things like source separation and transcription (see e.g Smaragdis and Brown, Non-Negative Matrix Factorization for Polyphonic Music Transcription.), although its creative potential is so far relatively unexplored. It works iteratively, by trying to find a combination of amplitudes ('activations') that yield the original magnitude spectrogram of the audio input when added together. By and large, there is no unique answer to this question (i.e. there are different ways of accounting for an evolving spectrum in terms of some set of templates and envelopes). In its basic form, NMF is a form of unsupervised learning: it starts with some random data and then converges towards something that minimizes the distance between its generated data and the original:it tends to converge very quickly at first and then level out. Fewer iterations mean less processing, but also less predictable results.

   The whole process can be related to a channel vocoder where, instead of fixed bandpass filters, we get more complex filter shapes and the activations correspond to channel envelopes.

:process: The realtime processing method. It takes an audio or control input, and will yield a control stream in the form of a multichannel array of size maxComponents . If the bases buffer has fewer than maxComponents channels, the remaining outputs will be zeroed.
:output: A multichannel kr output, giving for each basis component the activation amount.


:control in:

   The signal input to the factorisation process.

:control bases:

   The buffer containing the different bases that the input signal will be matched against. Bases must be (fft size / 2) + 1 frames. If the buffer has more than maxComponents channels, the excess will be ignored.

:control maxComponents:

   The maximum number of elements the NMF algorithm will try to divide the spectrogram of the source in. This dictates the number of output channels. This cannot be modulated.

:control iterations:

   The NMF process is iterative, trying to converge to the smallest error in its factorisation. The number of iterations will decide how many times it tries to adjust its estimates. Higher numbers here will be more CPU intensive, lower numbers will be more unpredictable in quality.

:control windowSize:

   The number of samples that are analysed at a time. A lower number yields greater temporal resolution, at the expense of spectral resolution, and vice-versa.

:control hopSize:

   The window hop size. As NMF relies on spectral frames, we need to move the window forward. It can be any size, but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

