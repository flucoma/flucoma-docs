:digest: Buffer-Based Dynamic Voice Allocation
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulation, Classes/SinOsc
:see-also: BufSines, BufSineFeature
:description: Dynamic frame based voice allocation on buffers
:discussion:
This process takes in buffers of related frequency and magnitude data, and just like :fluid-obj:`BufSines`, first tracks them as peaks to check if they are a continuation of a previous peak.

   After this track assignment, the number of peaks is capped to the user-defined ``numVoices`` in order of lowest frequency or loudest magnitude. The final step then assigns these peaks to voices and tracks their states.

:process: The non real time version of the object.
:output: The names of the three buffers in which the data has been stored: [0] is a buffer containing the frequencies, [1] is a buffer containing the magnitudes and [3] is a buffer containing their respective states. Each buffer has a channel per voice.

:control voiced:

    The buffer in which to store the processed voice state data.
    
:control birthhighthreshold:

    The threshold in dB above which to consider a peak to start tracking for the high end of the spectrum. It is interpolated across the spectrum until birthlowthreshold at DC.
    
:control birthlowthreshold:

    The threshold in dB above which to consider a peak to start tracking for the low end of the spectrum. It is interpolated across the spectrum until birthhighthreshold at half-nyquist.

:control freqed:

    The buffer in which to store the processed frequency data.
    
:control frequencies:

    The buffer from which to take frequency data from.
    
:control magned:

    The buffer in which to store the processed magnitude data.
    
:control magnitudes:

    The buffer from which to take magnitude data from.
    
:control maxnumvoices:

    Up to how many voices can be reported, by allocating memory at instantiation time. This cannot be modulated.
    
:control mintracklen:

    The minimum duration, in frames, for a track to be considered for a voice. It allows the removal of bubbly pitchy artefacts, but is more CPU intensive and might reject quick pitch material.
    
:control numchansa:
    
    For multichannel srcBuf, how many channels should be processed from the first buffer.
    
:control numchansb:
    
    For multichannel srcBuf, how many channels should be processed from the second buffer.
    
:control numframesa:

    How many frames should be processed from the first buffer.

:control numframesb:
    
    How many frames should be processed from the second buffer.
    
:control numvoices:

    The number of voices to keep track of and output. It is capped by ''maxnumvoices''.
    
:control prioritisedvoices:

    The order in which to prioritise peaks for voice assignment if an input array is bigger than ''numvoices''.
    
:control startchana:

    For multichannel srcBuf, which channel should be processed first for the first input buffer.

:control startchanb:

    For multichannel srcBuf, which channel should be processed first for the second input buffer.

:control startframea:

    Where in the srcBuf should the process start, in samples, for the first input buffer.

:control startframeb:

    Where in the srcBuf should the process start, in samples, for the second input buffer.

:control trackfreqrange:

    The frequency difference allowed for a track to diverge between frames, in Hertz.
    
:control trackmagrange:

    The amplitude difference allowed for a track to diverge between frames, in dB.
    
:control trackprob:

    The probability of the tracking algorithm to find a track.
