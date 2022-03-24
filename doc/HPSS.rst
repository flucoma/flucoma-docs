:digest: Harmonic-Percussive Source Separation Using Median Filtering
:species: transformer
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufHPSS, Sines, Transients
:description: Harmonic-Percussive Source Separation (HPSS) on an audio input.
:discussion: 
   HPSS takes in audio and divides it into two or three outputs, depending on the ``maskingMode``:
    * an harmonic component
    * a percussive component
    * a residual of the previous two if ``maskingMode`` is set to 2.

   HPSS works by using median filters on the magnitudes of a spectrogram. It makes certain assumptions about what it is looking for in a sound: that in a spectrogram “percussive” elements tend to form vertical “ridges” (tall in frequency band, narrow in time), while stable “harmonic” elements tend to form horizontal “ridges” (narrow in frequency band, long in time). By using median filters across time and frequency respectively, we get initial estimates of the "harmonic-ness" and "percussive-ness" for every spectral bin of every spectral frame in the spectrogram. These are then combined into 'masks' that are applied to the original spectrogram in order to produce a harmonic and percussive output (and residual if ``maskingMode`` = 2).

   The maskingMode parameter provides different approaches to combining estimates and producing masks. Some settings (especially in modes 1 & 2) will provide better separation but with more artefacts.
   
   Driedger (2014) suggests that the size of the median filters don't affect the outcome as much as the ``fftSize``. with large FFT sizes, short percussive sounds have less representation, therefore the harmonic component is more strongly represented. The result is that many of the percussive sounds leak into the harmonic component. Small FFT sizes have less resolution in the frequency domain and often lead to a blurring of horizontal structures, therefore harmonic sounds tend to leak into the percussive component. As with all FFT based-processes, finding an FFT size that balances spectral and temporal resolution for a given source sound will benefit the use of this object.

   For more details visit https://learn.flucoma.org/reference/hpss
   
   Fitzgerald, Derry. 2010. ‘Harmonic/Percussive Separation Using Median Filtering’. (In Proceedings DaFx 10. https://arrow.dit.ie/argcon/67.)
   
   Driedger, Jonathan, Meinard Müller, and Sascha Disch. 2014. ‘Extending Harmonic-Percussive Separation of Audio Signals’. (In Proc. ISMIR. http://www.terasoft.com.tw/conf/ismir2014/proceedings/T110_127_Paper.pdf.)

:process: The audio rate version of the object.
:output: An array of three audio streams: [0] is the harmonic part extracted, [1] is the percussive part extracted, [2] is the residual. This object will always have a residual output stream, but when using ``maskingMode`` 0 or 1 this stream will be silent. The latency between the input and the output is ((harmFilterSize - 1) * hopSize) + windowSize) samples.

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
         Soft masks provide the fewest artefacts, but the weakest separation. Complimentary, soft masks are made for the harmonic and percussive parts by allocating some fraction of every magnitude in the spectrogram to each mask. The two resulting buffers will sum to exactly the original material. This mode uses soft mask in Fitzgerald's (2010) original method of 'Wiener-inspired' filtering. 

      :1:
         Binary masks provide better separation, but with more artefacts. The harmonic mask is constructed using a binary decision, based on whether a threshold is exceeded for every magnitude in the spectrogram (these are set using ``harmThreshFreq1``, ``harmThreshAmp1``, ``harmThreshFreq2``, ``harmThreshAmp2``, see below). The percussive mask is then formed as the inverse of the harmonic one, meaning that as above, the two components will sum to the original sound.

      :2:
         Soft masks (with a third stream containing a residual component). First, binary masks are made separately for the harmonic and percussive components using different thresholds (set with the respective ``harmThresh-`` and ``percThresh-`` parameters below). Because these masks aren't guaranteed to represent the entire spectrogram, any residual energy is considered as a third output.  The independently created binary masks are converted to soft masks at the end of the process so that everything null sums. 

:control harmThresh:

   When ``maskingMode`` is 1 or 2, set the threshold curve for classifying an FFT bin as harmonic. Takes a list of two frequency-amplitude pairs as coordinates: between these coordinates the threshold is linearly interpolated, and is kept constant between DC and coordinate 1, and coordinate 2 and Nyquist.

:control percThresh:

   In ``maskingMode`` 2, an independent pair of frequency-amplitude pairs defining the threshold for the percussive part. Its format is the same as above.

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
