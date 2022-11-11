:digest: Buffer-Based Sinusoidal Peak Tracking
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulation, Classes/SinOsc
:see-also: SineFeature, BufSines
:description: Interpolated Sinusoidal Peak Tracking on the Spectrum of audio stored in a buffer.
:discussion: 
  This process is tracking peaks in the spectrum of audio stored in a buffer, then estimating an interpolated frequency and amplitude of that peak in relation to its spectral context. It is the first part of the process used by :fluid-obj:`BufSines`. 
  
  The process will return two buffers containing time series that describes the interpolated frequencies and magnitudes changing over time in the source buffer.

:process: This is the method that calls for the slicing to be calculated on a given source buffer.
:output: Nothing, as the various destination buffers are declared in the function call.

:control source:

  The |buffer| to use as the source material. The channels of multichannel buffers will be processed sequentially.

:control startFrame:

  The starting point for analysis in the source (in samples).

:control numFrames:

  The duration (in samples) to analyse.

:control startChan:

  For multichannel sources, the starting channel to analyse.

:control numChans:

  For multichannel sources, the number of channels to analyse.

:control frequency:

  The buffer where the interpolated frequency of the peaks will be written.

:control magnitude:

  The buffer where the interpolated magnitude of the peaks will be written.
      
:control numPeaks:

  The number of peaks to search report back. It is capped at (fftSize / 2) + 1.

:control detectionThreshold:

  The threshold in dB above which a magnitude peak is considered to be a sinusoidal component.

:control order:

  How the reported peaks are to be ordered. By default (0), it is by frequencies (lowest first), and the alternative (1) is by magnitude (loudest first).

:control freqUnit:

  The units and scale used to report the frequency of the peaks. By default (0), it is in Hz (linear), and the alternative (1) is in MIDI (logarithmic).

:control magUnit:

  The units and scale used to report the magnitude of the peaks. By default (0), it is in amp (linear), and the alternative (1) is in dB (logarithmic).

:control windowSize:

  The window size. As sinusoidal estimation relies on spectral frames, we need to decide what precision we give it spectrally and temporally. For more information visit https://learn.flucoma.org/learn/fourier-transform/

:control hopSize:

  The window hop size. As sinusoidal estimation relies on spectral frames, we need to move the window forward. It can be any size, but low overlap will create audible artefacts. The -1 default value will default to half of windowSize (overlap of 2).

:control fftSize:

  The inner FFT/IFFT size. It should be at least 4 samples long, at least the size of the window, and a power of 2. Making it larger allows an oversampling of the spectral precision. The -1 default value will default to windowSize. The -1 default value will default to the highest of windowSize and (bandwidth - 1) * 2.

:control padding:

   Controls the zero-padding added to either end of the source buffer or segment. Padding ensures all values are analysed. Possible values are:
   
   :enum:

      :0:
         No padding - The first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function.
   
      :1: 
         Half the window size - The first sample is centred in the analysis window ensuring that the start and end of the segment are accounted for in the analysis.
   
      :2: 
         Window size minus the hop size - Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.

:control maxFFTSize:

  How large can the FFT be, by allocating memory at instantiation time. This cannot be modulated.

:control maxNumPeaks:

  Up to how many peaks can be reported, by allocating memory at instantiation time. This cannot be modulated.
