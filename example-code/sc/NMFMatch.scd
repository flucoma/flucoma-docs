CODE::
/* For information on NMF and the associated Bases, please see the FluidBufNMF helpfile. */

// get some bases from this source file:
(
~scratchy = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));
~bases = Buffer(s);
~n_components = 2;
)

FluidBufNMF.processBlocking(s,~scratchy,bases:~bases,components:~n_components,action:{"done".postln;});

~bases.plot // find out which one is the single spiking sine tone and set the index equal to ~spike_base
~spike_base = 0;

// each time a match for that is found it will trigger sine tones at different frequencies
(
{
	var sig = PlayBuf.ar(1,~scratchy,BufRateScale.ir(~scratchy),loop:1);
	var match = FluidNMFMatch.kr(sig,~bases,~n_components);
	var spike_match = match[~spike_base].poll;
	var bool = spike_match > 2;
	var sine = SinOsc.ar(TRand.kr(-3.0.dup,3.0,bool).midiratio * 2500,mul:-40.dbamp * bool.lag(0.03));
	sig.dup + sine;
}.play;
)

// =========================================================================================================
// FluidNMFMatch can be trained on a small section of audio and then used to identify whenever similar audio
// appears again in the whole file or other files
// =========================================================================================================

// for example, take this 22 second field recording that has _some_ dog barking in it
~golcar = Buffer.readChannel(s,FluidFilesPath("Tremblay-BaB-SoundscapeGolcarWithDog.wav"),channels:[0]);

~golcar.play;

// we'll do a FluidBufNMF analysis on just the first 4 seconds (the part that has some dog bark in it);
~bases = Buffer(s);
FluidBufNMF.processBlocking(s,~golcar,numFrames:~golcar.sampleRate * 4,bases:~bases,components:2,action:{"done".postln;});

// and then play the whole 22 second sound file through FluidNMFMatch to see where in the sound file the spectral template
// of the dog bark is found. because the FluidBufNMF analysis starts from a stochastic state, we can't be sure which base
// contains the dog bark, but watching the green bars in this window will make very clear which one is detecting where
// in the sound file a dog bark is found
(
Task({
	var match = [0,0]; // an array for storing the output of FluidNMFMatch
	var win = Window("FluidNMFMatch",Rect(0,0,200,400));
	var uv = UserView(win,win.bounds)
	.drawFunc_{
		var w = uv.bounds.width / 2;
		Pen.color_(Color.green);
		match.do{ // iterate over the two values in the match array that are taken from FluidNMFMatch
			arg match_val, i;
			var match_norm = match_val.linlin(0,30,0,uv.bounds.height); // make it a height appropriate for the window
			var top = uv.bounds.height - match_norm; // offset from the top so it looks like it's a bar rising from the bottom
			/*top.postln;*/
			Pen.addRect(Rect(i * w,top,w,match_norm)); // draw the rect
			Pen.draw;
		};
	};

	{
		var sig = PlayBuf.ar(1,~golcar,BufRateScale.ir(~golcar),doneAction:2); // play the whole sound file

		// 30 times per second send the output of FluidNMFMatch to the language
		SendReply.kr(Impulse.kr(30),"/nmfmatch",FluidNMFMatch.kr(sig,~bases,2));
		sig;
	}.play;

	OSCdef(\nmfmatch,{ // catch the output of FluidNMFMatch in the language
		arg msg;
		match = msg[3..]; // populate the array that is used for plotting
		{uv.refresh}.defer; // and then refresh the window
	},"/nmfmatch");

	win.front;

},AppClock).play;
)
::

STRONG::A pick compressor::
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
FluidBufNMF.process(s,~guitar,0,88200,resynth:~resynth, bases:~bases, components:~n_components,fftSize:2048,action:{"done".postln;});

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

//using this trained basis we can see the envelop (activations) of each component
{FluidNMFMatch.kr(PlayBuf.ar(1,~guitar),~trainedBases,2,fftSize:2048)}.plot(1);
// the left/top activations are before, the pick before the sustain.

//we can then use the activation value to sidechain a compression patch that is sent in a delay
(
{
	var source, todelay, delay1, delay2, delay3, feedback, mod1, mod2, mod3, mod4;

	source = PlayBuf.ar(1, b);

	// generate modulators that are coprime in frequency
	mod1 = SinOsc.ar(1, 0, 0.001);
	mod2 = SinOsc.ar(((617 * 181) / (461 * 991)), 0, 0.001);
	mod3 = SinOsc.ar(((607 * 193) / (491 * 701)), 0, 0.001);
	mod4 = SinOsc.ar(((613 * 191) / (463 * 601)), 0, 0.001);

	// the signal to send to the delays
	todelay = DelayN.ar(source,0.1, 800/44100, //delaying it to compensate for FluidNMFMatch's latency
		LagUD.ar(K2A.ar(FluidNMFMatch.kr(source,~trainedBases,2,fftSize:2048)[0]), //reading the channel of the activations on the non-pick basis
			80/44100, // lag uptime (compressor's attack)
			1000/44100, // lag downtime (compressor's decay)
			(1/(2.dbamp) // compressor's threshold inverted
	)).clip(1,1000).pow((8.reciprocal)-1)); //clipping it so we only affect above threshold, then ratio(8) becomes the exponent of that base

	// delay network
	feedback = LocalIn.ar(3);// take the feedback in for the delays
	delay1 = DelayC.ar(BPF.ar(todelay+feedback[1]+(feedback[2] * 0.3), 987, 6.7,0.8),0.123,0.122+(mod1*mod2));
	delay2 = DelayC.ar(BPF.ar(todelay+feedback[0]+(feedback[2] * 0.3), 1987, 6.7,0.8),0.345,0.344+(mod3*mod4));
	delay3 = DelayC.ar(BPF.ar(todelay+feedback[1], 1456, 6.7,0.8),0.567,0.566+(mod1*mod3),0.6);
	LocalOut.ar([delay1,delay2, delay3]); // write the feedback for the delays

	source.dup + ([delay1+delay3,delay2+delay3]*(-3.dbamp));
	//listen to the delays in solo by uncommenting the following line
	// [delay1+delay3,delay2+delay3]
}.play;
)
::
STRONG::Strange Resonators::
CODE::

//load the source and declare buffers/arrays

(
~guitar = Buffer.read(s,File.realpath(FluidNMFMatch.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-AcousticStrums-M.wav");
~resynth = Buffer.new(s);
~bases = Buffer.new(s);
~spectralshapes = Buffer.new(s);
~stats = Buffer.new(s);
~n_components = 12;
~centroids = Array.newClear(~n_components);
)

// train only 2 seconds
FluidBufNMF.processBlocking(s,~guitar,0,88200,resynth:~resynth,bases:~bases, components:~n_components, hopSize:256, fftSize:2048,action:{"done".postln});

// extract the spectral centroid of all ~n_components components
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

(
// playback the "percussive" part of the sound buffer through BPFs centered on each centroid. The NMFMatch is being used to control the loudness of the outpout of these BPFs

x = {
	var sound = PlayBuf.ar(1,~guitar,loop:1);
	var  harm, perc, match, sig;

	# harm, perc = FluidHPSS.ar(sound, maskingMode:1, harmThreshFreq1: 0.005869, harmThreshAmp1: -9.6875, harmThreshFreq2: 0.006609, harmThreshAmp2: -4.375, hopSize:256);

	match = FluidNMFMatch.kr(DelayN.ar(sound,delaytime: ((17-1)*256)/44100), ~bases, maxComponents:~n_components, hopSize:256, fftSize:2048);

	sig = BPF.ar((harm / 4) + perc,~centroids,0.0015,(match * 2).lag(0.022));
	sig = Splay.ar(sig);

	sig = sig + perc.dup;

	sig;
}.play;
)
::
