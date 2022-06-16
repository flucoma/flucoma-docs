code::
/* For information on NMF and the associated Bases, please see the */ FluidBufNMF /* helpfile. */

// We'll start by getting some bases for this drum loop:
(
~drums = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));
~resynth = Buffer(s);
~bases = Buffer(s);
~n_components = 3;
)

// Process it:
FluidBufNMF.processBlocking(s,~drums,resynth:~resynth,resynthMode:1,bases:~bases,components:~n_components,action:{"done".postln;});

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
happening in real-time. */

// This means one could different FX to each instrument:

(
{
	var src = PlayBuf.ar(1,~drums,BufRateScale.ir(~drums),doneAction:2);
	var sig = FluidNMFFilter.ar(src,~bases,3);
	var mix;

	mix = Splay.ar(sig);

	mix = mix + CombN.ar(sig[2],0.1,[0.09,0.1],1.0);
	mix = mix + CombC.ar(sig[1],0.2,LFTri.kr(0.1).range(0.0,0.2));
	mix = mix + GVerb.ar(sig[0],100,7,0.9,drylevel:0,mul:-10.dbamp);

	mix;
}.play;
)

/* This also means that one could send a live input audio signal through FluidNMFFilter and get these
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

~song = Buffer.readChannel(s,FluidFilesPath("Tremblay-BeatRemember.wav"),channels:[0]);

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

::
STRONG::A guitar processor::
CODE::
//set some buffers
(
~guitar = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcousticStrums-M.wav"));
~resynth = Buffer.new(s);
~bases = Buffer.new(s);
~spectralshapes = Buffer.new(s);
~stats = Buffer.new(s);
~trainedBases = Buffer.new(s);
~n_components = 10;
~centroids = Array.newClear(~n_components);
)

// hear the guitar
~guitar.play;

// what we're going to try to achieve here is to use FluidNMFFilter to separate out the pick from the strings and do fx processing on them separately.

// train only 2 seconds, asking for 10 components
FluidBufNMF.process(s,~guitar,0,88200,resynth:~resynth, resynthMode:1, bases:~bases, components:~n_components,fftSize:2048,action:{"done".postln;});

// We're going to find the component that has the picking sound by doing a FluidSpectralShape analysis on each of the resynthesized components, then use FluidBufStats to get the median spectral centroid of each component.
(
fork{
	~n_components.do{
		arg i;
		// we'll do the spectral shape of the ~resynth buffer one channel at a time:
		FluidBufSpectralShape.processBlocking(s,~resynth,startChan:i,numChans:1,features:~spectralshapes);
		// telling FluidBufStats numChans = 1, means it will only analyze channel 0, which is spectral centroid
		FluidBufStats.processBlocking(s,~spectralshapes,numChans:1,stats:~stats);
		~stats.loadToFloatArray(action:{
			arg stats;
			~centroids[i] = stats[5]; // the median spectral centroid will be in index 5
		});
	};
	s.sync;
	~centroids.postln;
}
)

// Now we're going to create a new, 2 channel buffer to use as the bases for FluidNMFFilter. First we'll copy the basis with the lowest median centroid to channel 0, and all the *other* bases to channel 1. The hope here is that the base created for the resynthesized sound with the lowest median centroid will contain the sustain of the guitar strings, while all the others will contain components related to the "pick" part of the sound

(
~minIndex = ~centroids.minIndex;
~n_components.do{
	arg i;
	if(i == ~minIndex,{
		"base % has the lowest centroid".format(i).postln;
		FluidBufCompose.processBlocking(s,~bases,startChan:i,numChans:1,destination:~trainedBases,destStartChan:0);
	},{
		FluidBufCompose.processBlocking(s,~bases,startChan:i,numChans:1,destination:~trainedBases,destStartChan:1,destGain:1);
	});
};
)

~trainedBases.plot;

//we can then use the  signal to send to a delay
(
{
	var source, todelay, delay1, delay2, delay3, feedback, mod1, mod2, mod3, mod4;
	//read the source
	source = PlayBuf.ar(1, ~guitar);

	// generate modulators that are coprime in frequency
	mod1 = SinOsc.ar(1, 0, 0.001);
	mod2 = SinOsc.ar(((617 * 181) / (461 * 991)), 0, 0.001);
	mod3 = SinOsc.ar(((607 * 193) / (491 * 701)), 0, 0.001);
	mod4 = SinOsc.ar(((613 * 191) / (463 * 601)), 0, 0.001);

	// the signal to send to the delays
	todelay = FluidNMFFilter.ar(source,~trainedBases,2,fftSize:2048)[0]; //reading the channel of the activations on the pick basis

	// delay network
	feedback = LocalIn.ar(3);// take the feedback in for the delays
	delay1 = DelayC.ar(BPF.ar(todelay+feedback[1]+(feedback[2] * 0.3), 987, 6.7,0.8),0.123,0.122+(mod1*mod2));
	delay2 = DelayC.ar(BPF.ar(todelay+feedback[0]+(feedback[2] * 0.3), 1987, 6.7,0.8),0.345,0.344+(mod3*mod4));
	delay3 = DelayC.ar(BPF.ar(todelay+feedback[1], 1456, 6.7,0.8),0.567,0.566+(mod1*mod3),0.6);
	LocalOut.ar([delay1,delay2, delay3]); // write the feedback for the delays

	source.dup + ([delay1+delay3,delay2+delay3]*(3.dbamp));
	//listen to the delays in solo by uncommenting the following line
	// [delay1+delay3,delay2+delay3]
	// [source, todelay]
}.play;
)
::
