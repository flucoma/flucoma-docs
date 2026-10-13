:digest: Dynamic Voice Allocation
:species: transformer
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Classes/SinOsc
:see-also: Sines, SineFeature
:description: Dynamic frame based voice allocation.
:discussion: 
   This process takes in arrays of related frequency and magnitude data, and just like :fluid-obj:`Sines`, first tracks them as peaks to check if they are a continuation of a previous peak.

   After this track assignment, the number of peaks is capped to the user-defined ``numVoices`` in order of lowest frequency or loudest magnitude. The final step then assigns these peaks to voices and tracks their states.

:process: The control rate version of the object.
:output: An array of three control streams: [0] is the frequency of each voice, [1] is their respective magnitudes, and [2] is their respective states. The latency between the input and the output is 0 samples.


:control in:

   The input to be processed

:control numVoices:
   
   The number of voices to keep track of and output. It is capped by ``maxNumVoices``

:control prioritisedVoices:

   The order in which to prioritise peaks for voice assignment if an input array is bigger than ``numVoices``.

:control birthLowThreshold:

   The threshold in dB above which to consider a peak to start tracking, for the low end of the spectrum. It is interpolated across the spectrum until birthHighThreshold at half-Nyquist.

:control birthHighThreshold:

   The threshold in dB above which to consider a peak to start tracking, for the high end of the spectrum. It is interpolated across the spectrum until birthLowThreshold at DC.

:control minTrackLen:

   The minimum duration, in frames, for a track to be considered for a voice. It allows to remove bubbly pitchy artefacts, but is more CPU intensive and might reject quick pitch material.

:control trackMethod:

   Currently not implemented as 
   The algorithm used to track peak continuity between frames. 0 is the default, "Greedy", and 1 is a more expensive [^"Hungarian"]( Neri, J., and Depalle, P., "Fast Partial Tracking of Audio with Real-Time Capability through Linear Programming". Proceedings of DAFx-2018. ) one.

:control trackMagRange:

   The amplitude difference allowed for a track to diverge between frames, in dB.

:control trackFreqRange:

   The frequency difference allowed for a track to diverge between frames, in Hertz.

:control trackProb:

   The probability of the tracking algorithm to find a track.

:control maxNumVoices:

   Up to how many voices can be reported, by allocating memory at instantiation time. This cannot be modulated.