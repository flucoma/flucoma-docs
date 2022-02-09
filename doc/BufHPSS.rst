:digest: Buffer-Based Harmonic-Percussive Source Separation Using Median Filtering
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: HPSS, BufSines, BufTransients
:description: FluidBufHPSS performs Harmonic-Percussive Source Separation (HPSS) on the contents of a Buffer.
:discussion: 
   HPSS works by using median filters on the spectral magnitudes of a sound. It hinges on a simple modelling assumption that tonal components will tend to yield concentrations of energy across time, spread out in frequency, and percussive components will manifest as concentrations of energy across frequency, spread out in time. By using median filters across time and frequency respectively, we get initial esitmates of the tonal-ness / transient-ness of a point in time and frequency. These are then combined into 'masks' that are applied to the orginal spectral data in order to produce a separation.

   The maskingMode parameter provides different approaches to combinging estimates and producing masks. Some settings (especially in modes 1 & 2) will provide better separation but with more artefacts. These can, in principle, be ameliorated by applying smoothing filters to the masks before transforming back to the time-domain (not yet implemented).

:process: This is the method that calls for the HPSS to be calculated on a given source buffer.
:output: Nothing, as the various destination buffers are declared in the function call.


:control source:

   The index of the buffer to use as the source material. The channels of multichannel buffers will be processed sequentially.

:control startFrame:

   Where in the srcBuf should the HPSS process start, in samples.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel to start processing at.

:control numChans:

   For multichannel srcBuf, how many channels should be processed.

:control harmonic:

   The index of the buffer where the extracted harmonic component will be reconstructed.

:control percussive:

   The index of the buffer where the extracted percussive component will be reconstructed.

:control residual:

   The index of the buffer where the residual component will be reconstructed in mode 2.

:control harmFilterSize:

   The size, in spectral frames, of the median filter for the harmonic component. Must be an odd number, >= 3.

:control percFilterSize:

   The size, in spectral bins, of the median filter for the percussive component. Must be an odd number, >=3

:control maskingMode:

   The way the masking is applied to the original spectrogram.

   :enum:

      :0:
         The traditional soft mask used in Fitzgerald's original method of 'Wiener-inspired' filtering. Complimentary, soft masks are made for the harmonic and percussive parts by allocating some fraction of a point in time-frequency to each. This provides the fewest artefacts, but the weakest separation. The two resulting buffers will sum to exactly the original material.

      :1:
         Relative mode - Better separation, with more artefacts. The harmonic mask is constructed using a binary decision, based on whether a threshold is exceeded at a given time-frequency point (these are set using harmThreshFreq1, harmThreshAmp1, harmThreshFreq2, harmThreshAmp2, see below). The percussive mask is then formed as the inverse of the harmonic one, meaning that as above, the two components will sum to the original sound.

      :2:
         Inter-dependent mode - Thresholds can be varied independently, but are coupled in effect. Binary masks are made for each of the harmonic and percussive components, and the masks are converted to soft at the end so that everything null sums even if the params are independent, that is what makes it harder to control. These aren't guranteed to cover the whole sound; in this case the 'leftovers' will placed into a third buffer.

:control harmThresh:

   When maskingmode is 1 or 2, set the threshold curve for classifying an FFT bin as harmonic. Takes a list of two frequency-amplitude pairs as coordinates: between these coordinates the threshold is linearly interpolated, and is kept constant between DC and coordinate 1, and coordinate 2 and Nyquist.

:control percThresh:

   In maskingmode 2, an independant pair of frequency-amplitude pairs defining the threshold for the percussive part. Its format is the same as above.

:control windowSize:

   The window size in samples. As HPSS relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The hop size in samples. As HPSS relies on spectral frames, we need to move the window forward. It can be any size but low overlap may create audible artefacts.

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long; at least the size of the window; and a power of 2. Making it larger than the window size provides interpolation in frequency.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

:control maxHarmFilterSize:

   How large can the harmonic filter be modulated to (harmFilterSize), by allocating memory at instantiation time. This cannot be modulated.

:control maxPercFilterSize:

   How large can the percussive filter be modulated to (percFilterSize), by allocating memory at instantiation time. This cannot be modulated.

