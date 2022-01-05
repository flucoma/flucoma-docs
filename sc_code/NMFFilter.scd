/* For information on NMF and the associated Bases, please see the */ FluidBufNMF /* helpfile. */

// We'll start by getting some bases for this drum loop:
(
~drums = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));
~resynth = Buffer(s);
~bases = Buffer(s);
~n_components = 3;
)

// Process it:
FluidBufNMF.processBlocking(s,~drums,resynth:~resynth,bases:~bases,components:~n_components,action:{"done".postln;});

// Once it is done, let's hear what components it was able to decompose:
// Play the separated components one by one (with a second of silence in between).
(
fork{
	~n_components.do{
		arg i;
		"decomposed part #%".format(i+1).postln;
		{
			PlayBuf.ar(~n_components,~resynth,BufRateScale.ir(~resynth),doneAction:2)[i].dup;
		}.play;
		(~drums.duration + 1).wait;
	}
};
)

// If the process did not separate out the kick drum, hi hat, and snare drum (in any order) very well, try it again until it does.
// It will be useful going forward to have bases that pretty well represent these drum instruments.

// FluidNMFFilter will use the bases (spectral templates) of a FluidBufNMF analysis to filter (i.e., decompose) real-time audio
// First, we'll just send the same drum loop through FluidNMFFilter to hear it in action:
(
fork{
	~n_components.do{
		arg i;
		"decomposed part #% filtered in real-time using FluidNMFFilter".format(i+1).postln;
		{
			var src = PlayBuf.ar(1,~drums,BufRateScale.ir(~drums),doneAction:2);
			var sig = FluidNMFFilter.ar(src,~bases,~n_components)[i];
			sig;
		}.play;
		(~drums.duration + 1).wait;
	}
};
)

/* It is seprating the drum instrument components just like it did with FluidBufNMF--the difference here is that it is
happening in real-time. This means that one could also send a live input audio signal through FluidNMFFilter and get these
drum instruments similarly decomposed into separate audio streams in *real-time*. */

/* To test an idea like this, we could train it on just the first few seconds of this drum loop (like a training set when using
a neural network) and then see how it peforms on audio it hasn't seen before: the rest of the drum loop (similar to using
a testing set when working with a neural network) */

(
~split_point_seconds = 3;
// load a training buffer with only the first part of the drum loop:
~drums_training = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"),numFrames:~drums.sampleRate * ~split_point_seconds);
// load a testing buffer with the rest:
~drums_testing = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"),startFrame:~drums.sampleRate * ~split_point_seconds);
~bases_from_training = Buffer(s);
)

// Process it:
FluidBufNMF.processBlocking(s,~drums_training,bases:~bases_from_training,components:3,action:{"done".postln;});

// Hear it:
(
fork{
	3.do{
		arg i;
		"decomposed part #% filtered in real-time using FluidNMFFilter\n\tIt has never heard this part of the drum loop!\n".format(i+1).postln;
		{
			var src = PlayBuf.ar(1,~drums_testing,BufRateScale.ir(~drums_testing),doneAction:2);
			var sig = FluidNMFFilter.ar(src,~bases_from_training,3)[i];
			sig;
		}.play;
		(~drums_testing.duration + 1).wait;
	}
};
)

// If we play a different source through FluidNMFFilter, it will try to decompose that real-time signal according to the bases
// it is given (in our case the bases from the drum loop)

~song = Buffer.readChannel(s,FluidFilesPath("Tremblay-beatRemember.wav"),channels:[0]);

(
fork{
	~n_components.do{
		arg i;
		"decomposed part #% filtered in real-time using FluidNMFFilter".format(i+1).postln;
		{
			var src = PlayBuf.ar(1,~song,BufRateScale.ir(~song),doneAction:2);
			var sig = FluidNMFFilter.ar(src,~bases,~n_components)[i];
			sig;
		}.play;
		(~song.duration + 1).wait;
	}
};
)

/* FluidNMFFilter has pretty well been able to identify and filter the kick drum, snare drum, and hi hat in this song
using on the corresponding bases from the ~drums analysis. It isn't perfect because it wasn't trained on these
specific drum sounds and how they exist in this ensemble recording. */
