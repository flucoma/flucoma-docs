:digest: Buffer-Based Non-Negative Matrix Factorisation on Spectral Frames
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulation
:see-also: NMFMatch, NMFFilter
:description: Decomposes the spectrum of a sound into a number of components using Non-Negative Matrix Factorisation (NMF)
:discussion: 
   NMF has been a popular technique in signal processing research for things like source separation and transcription (see Smaragdis and Brown, Non-Negative Matrix Factorization for Polyphonic Music Transcription.), although its creative potential is so far relatively  unexplored.

   The algorithm takes a buffer in and divides it into a number of components, determined by the components argument. It works iteratively, by trying to find a combination of spectral templates ('bases') and envelopes ('activations') that yield the original magnitude spectrogram when added together. By and large, there is no unique answer to this question (i.e. there are different ways of accounting for an evolving spectrum in terms of some set of templates and envelopes). In its basic form, NMF is a form of unsupervised learning: it starts with some random data and then converges towards something that minimises the distance between its generated data and the original:it tends to converge very quickly at first and then level out. Fewer iterations mean less processing, but also less predictable results.

   The object can return either or all of the following:
   	* a spectral contour of each component in the form of a magnitude spectrogram (called a basis in NMF lingo);
   	* an amplitude envelope of each component in the form of gains for each consecutive frame of the underlying spectrogram (called an activation in NMF lingo);
   	* an audio reconstruction of each component in the time domain.

   The bases and activations can be used to make a kind of vocoder based on what NMF has 'learned' from the original data. Alternatively, taking the matrix product of a basis and an activation will yield a synthetic magnitude spectrogram of a component (which could be reconstructed, given some phase information from somewhere).

   Some additional options and flexibility can be found through combinations of the basesMode and actMode arguments. If these flags are set to 1, the object expects to be supplied with pre-formed spectra (or envelopes) that will be used as seeds for the decomposition, providing more guided results. When set to 2, the supplied buffers won't be updated, so become templates to match against instead. Note that having both bases and activations set to 2 doesn't make sense, so the object will complain.

   If supplying pre-formed data, it's up to the user to make sure that the supplied buffers are the right size:
     * bases must be ``(fft size / 2) + 1`` frames and ``(components * input channels)`` channels
     * activations  must be ``(input frames / hopSize) + 1`` frames and ``(components * input channels)`` channels

   In this implementation, the components are reconstructed by masking the original spectrum, such that they will sum to yield the original sound.

   The whole process can be related to a channel vocoder where, instead of fixed bandpass filters, we get more complex filter shapes that are learned from the data, and the activations correspond to channel envelopes.

:process: This is the method that calls for the factorisation to be calculated on a given source buffer.
:output: Nothing, as the various destination buffers are declared in the function call.


:control source:

   The buffer to use as the source material to be decomposed through the NMF process. The different channels of multichannel buffers will be processed sequentially.

:control startFrame:

   Where in the srcBuf should the NMF process start, in samples.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel should be processed first.

:control numChans:

   For multichannel srcBuf, how many channels should be processed.

:control resynth:

   The buffer where the different reconstructed components will be reconstructed. The buffer will be resized to ``components * numChannelsProcessed`` channels and ``sourceDuration`` length. If ``nil`` is provided, the reconstruction will not happen.

:control resynthMode:

   This flag determines if resynthesis from basis and activation is executed.

:control bases:

   The buffer where the different bases will be written to and/or read from: the behaviour is set in the following argument. If ``nil`` is provided, no bases will be returned.

:control basesMode:

   This flag decides how the basis buffer passed as the previous argument is treated.

   :enum:

      :0:
         The bases are seeded randomly, and the resulting ones will be written after the process in the passed buffer. The buffer is resized to ``components * numChannelsProcessed`` channels and ``(fftSize / 2 + 1)`` length.

      :1:
         The passed buffer is considered as seed for the bases. Its dimensions should match the values above. The resulting bases will replace the seed ones.

      :2:
         The passed buffer is considered as a template for the bases, and will therefore not change. Its bases should match the values above.

:control activations:

   The buffer where the different activations will be written to and/or read from: the behaviour is set in the following argument. If ``nil`` is provided, no activation will be returned.

:control actMode:

   This flag decides how the activation buffer passed as the previous argument is treated.

   :enum:

      :0:
         The activations are seeded randomly, and the resulting ones will be written after the process in the passed buffer. The buffer is resized to ``components * numChannelsProcessed`` channels and ``(sourceDuration / hopsize + 1)`` length.

      :1:
         The passed buffer is considered as seed for the activations. Its dimensions should match the values above. The resulting activations will replace the seed ones.

      :2:
         The passed buffer is considered as a template for the activations, and will therefore not change. Its dimensions should match the values above.

:control components:

   The number of elements the NMF algorithm will try to divide the spectrogram of the source in.

:control iterations:

   The NMF process is iterative, trying to converge to the smallest error in its factorisation. The number of iterations will decide how many times it tries to adjust its estimates. Higher numbers here will be more CPU expensive, lower numbers will be more unpredictable in quality.

:control windowSize:

   The window size. As NMF relies on spectral frames, we need to decide what precision we give it spectrally and temporally. For more information visit https://learn.flucoma.org/learn/fourier-transform/

:control hopSize:

   The window hop size. As NMF relies on spectral frames, we need to move the window forward. It can be any size, but low overlap will create audible artefacts.

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision.

:control winType:

   The inner FFT/IFFT windowing type (not implemented yet)

:control randSeed:

   The NMF process needs to seed its starting point. If specified, the same values will be used. The default of -1 will randomly assign them. (not implemented yet)

:control action:

   A Function to be evaluated once the offline process has finished and all Buffer's instance variables have been updated on the client side. The function will be passed [resynth, bases, activations] as an argument.

