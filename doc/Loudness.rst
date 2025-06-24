:digest: A Loudness and True-Peak Descriptor in Realtime
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Classes/Amplitude
:see-also: BufLoudness, Pitch, MelBands, MFCC, SpectralShape
:max-seealso: peakamp~, meter~
:description: Two loudness descriptors, with a ITU BS 1770 mode
:discussion: 
   Computes the true peak of the signal as well as applying the filters proposed by broadcasting standards to emulate the perception of amplitude.

   The process will return a multichannel control stream with [loudness, truepeak] values, both in dBFS, which will be repeated if no change happens within the algorithm, i.e. when the hopSize is larger than the signal vector size. More information on broadcasting standardisation of loudness measurement is available at the reference page ( https://tech.ebu.ch/docs/tech/tech3341.pdf ) and in more musician-friendly explantions here (http://designingsound.org/2013/02/06/loudness-and-metering-part-1/).

:process: The audio rate in, control rate out version of the object.
:output: A 2-channel KR signal with the [loudness, peak] descriptors. The latency is windowSize.


:control in:

   The audio to be processed.

:control select:

   An array of ``symbols`` indicating which analyses to return. The options are ``loudness`` and ``peak``. If nothing is specified, the object will return all the analyses. The analyses will always appear in their normal order, this argument just allows for a selection of them to be returned. Reordering the options in this argument will not reorder how the analyses are returned.

:control kWeighting:

   A flag to switch the perceptual model of loudness. On by default, removing it makes the algorithm more CPU efficient by reverting to a simple RMS of the frame.

:control truePeak:

   A flag to switch the computation of TruePeak. On by default, removing it makes the algorithm more CPU efficient by reverting to a simple absolute peak of the frame.

:control windowSize:

   The size of the window on which the computation is done. By default 1024 to be similar with all other FluCoMa objects, the EBU specifies 400ms, which is 17640 samples at 44100.

:control hopSize:

   How much the buffered window moves forward, in samples. By default 512 to be similar with all other FluCoMa objects, the EBU specifies 100ms, which is 4410 samples at 44100.

:control maxWindowSize:

   How large can the windowSize be, by allocating memory at instantiation time. This cannot be modulated.

