
STRONG::Mode 0::

CODE::

//load buffers
(
~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));
~harmonic = Buffer.new(s);
~percussive = Buffer.new(s);
)

// run with basic parameters
FluidBufHPSS.processBlocking(s,~src,harmonic:~harmonic,percussive:~percussive,action:{"done".postln;});

//play the harmonic
~harmonic.play;

//play the percussive
~percussive.play;

(
// See which parts of the Waveform are in which component
// blue = harmonic, orange = percussive
~fw = FluidWaveform(bounds:Rect(0,0,1600,400));
~fw.addAudioLayer(~harmonic,FluidViewer.categoryColors[0].alpha_(0.5));
~fw.addAudioLayer(~percussive,FluidViewer.categoryColors[1].alpha_(0.5));
~fw.front;
)

::

STRONG::Separating Components before Analysis (using Mode 1)::

CODE::

~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));

// hear it
~src.play;

// let's look at some pitch analysis first
(
~pitch_analysis = Buffer(s);
FluidBufPitch.processBlocking(s,~src,features:~pitch_analysis,minFreq:40,maxFreq:500,windowSize:4096);
FluidWaveform(~src,featuresBuffer:~pitch_analysis,bounds:Rect(0,400,1600,400),stackFeatures:true);
)
// it's getting the "pitch" of all the clicks (the peaky spikes in the blue pitch plot),
// but perhaps I just want the pitch analysis of the bass line

// now let's do the pitch analysis using just the harmonic component
// because we're interested in strong separation and don't need to care about artefacts, maskingMode = 1
(
~harmonic = Buffer(s);
FluidBufHPSS.processBlocking(s,~src,harmonic:~harmonic,harmFilterSize:17,percFilterSize:31,maskingMode:1);
FluidBufPitch.processBlocking(s,~harmonic,features:~pitch_analysis,minFreq:40,maxFreq:500,windowSize:4096);
FluidWaveform(~harmonic,featuresBuffer:~pitch_analysis,bounds:Rect(0,0,1600,400),stackFeatures:true);
)
// except for a few spikes at the end, this is much more usable for extracting the pitch of the bass notes.

// take a listen to what it's analyzing
~harmonic.play;

::

STRONG::Mode 2::

CODE::

(
~src = Buffer.read(s,FluidFilesPath("Tremblay-CF-ChurchBells.wav"));
~residual = Buffer.new(s);
~harmonic = Buffer.new(s);
~percussive = Buffer.new(s);
)

// listen to the original;
~src.play

(
// this will take a few seconds (wait for "done" to post):
FluidBufHPSS.processBlocking(s,~src,harmonic:~harmonic,percussive:~percussive,residual:~residual,harmFilterSize:71,percFilterSize:31,maskingMode:2,harmThreshFreq1:0.005,harmThreshAmp1:3,harmThreshFreq2:0.2,harmThreshAmp2:6,percThreshFreq1:0.004,percThreshAmp1:3,percThreshFreq2:0.152,percThreshAmp2:3,windowSize:4096,hopSize:512,action:{"done".postln;})
)

// listen to the different parts
~harmonic.play; // some artefacts, but mostly the "harmonic" partials of the bells
~percussive.play; // has most of the "noisy" content of the bell resonance
~residual.play; // a bit of both, more of the attack

::
