:digest: A Loudness and True-Peak Descriptor on a Buffer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: Loudness, BufPitch, BufMelBands, BufMFCC, BufSpectralShape, BufStats
:description: Two loudness descriptors, computing the true peak of the signal as well as applying the filters proposed by broadcasting standards to emulate the perception of amplitude.
:discussion: 
   The process will return a multichannel buffer with two channels per input channel, one for loudness and one for the true peak value of the frame, both in dBfs.

   More information on broadcasting standardisation of loudness measurement is available at https://tech.ebu.ch/docs/tech/tech3341.pdf, and in more musician-friendly explantions at http://designingsound.org/2013/02/06/loudness-and-metering-part-1/.

   Each sample represents a value, which is every hopSize. Its sampling rate is sourceSR / hopSize.

:process: This is the method that calls for the loudness descriptor to be calculated on a given source buffer.
:output: Nothing, as the destination buffer is declared in the function call.


:control source:

   The index of the buffer to use as the source material to be described. The different channels of multichannel buffers will be processing sequentially.

:control startFrame:

   Where in the srcBuf should the process start, in sample.

:control numFrames:

   How many frames should be processed.

:control startChan:

   For multichannel srcBuf, which channel should be processed first.

:control numChans:

   For multichannel srcBuf, how many channel should be processed.

:control features:

   The destination buffer for the loudness descriptors.

:control kWeighting:

   A flag to switch the perceptual model of loudness. On by default, removing it makes the algorithm more CPU efficient by reverting to a simple RMS of the frame.

:control truePeak:

   A flag to switch the computation of TruePeak. On by default, removing it makes the algorithm more CPU efficient by reverting to a simple absolute peak of the frame.

:control windowSize:

   The size of the window on which the computation is done. By default 1024 to be similar with all other FluCoMa objects, the EBU specifies 400ms, which is 17640 samples at 44100.

:control hopSize:

   How much the buffered window moves forward, in samples. By default 512 to be similar with all other FluCoMa objects, the EBU specifies 100ms, which is 4410 samples at 44100.

:control padding:

   Controls the zero-padding added to either end of the source buffer or segment. Possible values are 0 (no padding), 1 (default, half the window size), or 2 (window size - hop size). Padding ensures that all input samples are completely analysed: with no padding, the first analysis window starts at time 0, and the samples at either end will be tapered by the STFT windowing function. Mode 1 has the effect of centering the first sample in the analysis window and ensuring that the very start and end of the segment are accounted for in the analysis. Mode 2 can be useful when the overlap factor (window size / hop size) is greater than 2, to ensure that the input samples at either end of the segment are covered by the same number of analysis frames as the rest of the analysed material.

:control maxWindowSize:

   How large can the windowSize be, by allocating memory at instantiation time. This cannot be modulated.

:control action:

   A Function to be evaluated once the offline process has finished and all Buffer's instance variables have been updated on the client side. The function will be passed [features] as an argument.

