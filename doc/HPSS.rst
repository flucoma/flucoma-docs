:digest: Harmonic-Percussive Source Separation Using Median Filtering
:species: transformer
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufHPSS, Sines, Transients
:description: Harmonic-Percussive Source Separation (HPSS) on an audio input.
:discussion: 
   HPSS takes in audio and divides it into two or three outputs, depending on the mode:
   	* an harmonic component
   	* a percussive component
   	* a residual of the previous two if the flag is set to inter-dependant thresholds. See the maskingMode below.

   HPSS works by using median filters on the magnitudes of a spectrogram. It makes certain assumptions about what it is looking for in a sound: it is based on the observation that in a spectrogram “percussive” elements tend to form vertical “ridges” (tall in frequency band, narrow in time), while stable “harmonic” elements tend to form horizontal “ridges” (narrow in frequency band, long in time). By using median filters across time and frequency respectively, we get initial esitmates of the harominc-ness and percussive-ness of a point in time and frequency. These are then combined into 'masks' that are applied to the orginal spectrogram in order to produce a harmonic and percussive output (and residual if maskingMode = 2).

   The maskingMode parameter provides different approaches to combining estimates and producing masks. Some settings (especially in modes 1 & 2) will provide better separation but with more artefacts.

   For more details visit https://learn.flucoma.org/reference/hpss

   These processes are described in:
   Fitzgerald, Derry. 2010. ‘Harmonic/Percussive Separation Using Median Filtering’. (In Proceedings DaFx 10. https://arrow.dit.ie/argcon/67.)
   It also provides the variation detailed in Driedger, Jonathan, Meinard Müller, and Sascha Disch. 2014. ‘Extending Harmonic-Percussive Separation of Audio Signals’. (In Proc. ISMIR. http://www.terasoft.com.tw/conf/ismir2014/proceedings/T110_127_Paper.pdf.)

:process: The audio rate version of the object.
:output: An array of three audio streams: [0] is the harmonic part extracted, [1] is the percussive part extracted, [2] is the rest. The latency between the input and the output is ((harmFilterSize - 1) * hopSize) + windowSize) samples.


:control in:

   The input to be processed.

:control harmFilterSize:

   The size, in spectral frames, of the median filter for the harmonic component. Must be an odd number, >= 3.

:control percFilterSize:

   The size, in spectral bins, of the median filter for the percussive component. Must be an odd number, >=3

:control maskingMode:

   The way the masking is applied to the original spectrogram. (0,1,2)

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

   The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally, in line with Gabor Uncertainty principles. http://www.subsurfwiki.org/wiki/Gabor_uncertainty

:control hopSize:

   The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

   The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize.

:control maxFFTSize:

   How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

:control maxHarmFilterSize:

   How large can the harmonic filter be modulated to (harmFilterSize), by allocating memory at instantiation time. This cannot be modulated.

:control maxPercFilterSize:

   How large can the percussive filter be modulated to (percFilterSize), by allocating memory at instantiation time. This cannot be modulated.

