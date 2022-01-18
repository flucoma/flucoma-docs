STRONG::A didactic example::
CODE::
(
// create buffers
b= Buffer.alloc(s,44100);
c = Buffer.alloc(s, 44100);
d = Buffer.new(s);
e= Buffer.new(s);
)

(
// fill them with 2 clearly segregated sine waves and composite a buffer where they are consecutive
Routine {
	b.sine2([500],[1], false, false);
	c.sine2([5000],[1],false, false);
	s.sync;
	FluidBufCompose.process(s,b, destination:d);
	FluidBufCompose.process(s,c, destStartFrame:44100, destination:d, destGain:1);
	s.sync;
	d.query;
}.play;
)

// check
d.plot
d.play //////(beware !!!! loud!!!)

(
// separate them in 2 components
Routine {
	FluidBufNMF.process(s, d, bases: e, components:2);
	s.sync;
	e.query;
}.play
)

// check for 2 spikes in the spectra
e.plot

// test the activations values with test one, another, or both ideal material
{FluidNMFMatch.kr(SinOsc.ar(500),e,2)}.plot(1)

{FluidNMFMatch.kr(SinOsc.ar(5000),e,2)}.plot(1)

{FluidNMFMatch.kr(SinOsc.ar([500,5000]).sum,e,2)}.plot(1)
::

STRONG::A pick compressor::
CODE::
//set some buffers
(
b = Buffer.read(s,File.realpath(FluidNMFMatch.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-AcousticStrums-M.wav");
c = Buffer.new(s);
~bases = Buffer.new(s);
~spectralshapes = Buffer.new(s);
~stats = Buffer.new(s);
~centroids = Array.new();
~trainedBases = Buffer.new(s);
)

// train only 2 seconds
(
Routine {
    FluidBufNMF.process(s,b,0,88200,0,1, c, ~bases, components:10,fftSize:2048).wait;
    c.query;
}.play;
)

// wait for the query to print
// find the component that has the picking sound checking the median spectral centroid
(
FluidBufSpectralShape.process(s, c, features: ~spectralshapes, action:{
	|shapes|FluidBufStats.process(s,shapes,stats:~stats, action:{
		|stats|stats.getn(0, (stats.numChannels * stats.numFrames) ,{
			|x| ~centroids = x.select({
				|item, index| (index.mod(7) == 0) && (index.div(70) == 5);
			})
		})
	})
});
)

// we then copy the basis with the highest median centroid to a channel, and all the other bases to the other channel, of a 2-channel bases for decomposition
(
z = (0..9);
[z.removeAt(~centroids.maxIndex)].do{|chan|FluidBufCompose.process(s, ~bases, startChan: chan, numChans: 1, destination: ~trainedBases, destGain:1)};
z.postln;
z.do({|chan| FluidBufCompose.process(s, ~bases, startChan:chan, numChans: 1, destStartChan: 1, destination: ~trainedBases, destGain:1)});
)

~trainedBases.plot;

//using this trained basis we can see the envelop (activations) of each component
{FluidNMFMatch.kr(PlayBuf.ar(1,b),~trainedBases,2,fftSize:2048)}.plot(1);
// the left/top activations are before, the pick before the sustain.

//we can then use the activation value to sidechain a compression patch that is sent in a delay
(
{
	var source, todelay, delay1, delay2, delay3, feedback, mod1, mod2, mod3, mod4;
	//read the source
	source = PlayBuf.ar(1, b);

	// generate modulators that are coprime in frequency
	mod1 = SinOsc.ar(1, 0, 0.001);
	mod2 = SinOsc.ar(((617 * 181) / (461 * 991)), 0, 0.001);
	mod3 = SinOsc.ar(((607 * 193) / (491 * 701)), 0, 0.001);
	mod4 = SinOsc.ar(((613 * 191) / (463 * 601)), 0, 0.001);

	// compress the signal to send to the delays
	todelay = DelayN.ar(source,0.1, 800/44100, //delaying it to compensate for FluidNMFMatch's latency
		LagUD.ar(K2A.ar(FluidNMFMatch.kr(source,~trainedBases,2,fftSize:2048)[0]), //reading the channel of the activations on the pick basis
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

	source.dup + ([delay1+delay3,delay2+delay3]*(-3.dbamp))
	//listen to the delays in solo by uncommenting the following line
	// [delay1+delay3,delay2+delay3]
}.play;
)

::


	STRONG::Strange Resonators::
	CODE::
//load the source and declare buffers/arrays
(
b = Buffer.read(s,File.realpath(FluidNMFMatch.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-AcousticStrums-M.wav");
c = Buffer.new(s);
~bases = Buffer.new(s);
~spectralshapes = Buffer.new(s);
~stats = Buffer.new(s);
~centroids = Array.new();
)

// train only 2 seconds
(
Routine {
    FluidBufNMF.process(s,b,0,88200,0,1, c, ~bases, components:8, hopSize:256, fftSize:2048).wait;
    c.query;
}.play;
)

// wait for the query to print
// find the component that has the picking sound checking the median spectral centroid
(
FluidBufSpectralShape.process(s, c, features: ~spectralshapes, action:{
	|shapes|FluidBufStats.process(s,shapes,stats:~stats, action:{
		|stats|stats.getn(0, (stats.numChannels * stats.numFrames) ,{
			|x| ~centroids = x.select({
				|item, index| (index.mod(7) == 0) && (index.div(56) == 5);
			})
		})
	})
});
)

//the interleave format is 7 stats(frames) x 8 components in the source as tracks x 7 shapes (tracks)
~stats.query
~centroids.size()

// make a player with harmonic on the out0, percussive on the out1, and 8 ctlout of nmfmatch
~splitaudio = Bus.audio(s,1);
~nmfenvs = Bus.control(s,8);

// start the player and you should hear only the pick a little
(
x = {
	var sound = PlayBuf.ar(1,b,loop:1);
	var  harm, perc;
	# harm, perc = FluidHPSS.ar(sound, maskingMode:1, harmThreshFreq1: 0.005869, harmThreshAmp1: -9.6875, harmThreshFreq2: 0.006609, harmThreshAmp2: -4.375, hopSize:256);
	Out.ar(~splitaudio, (harm / 4) + perc);
	Out.kr(~nmfenvs, FluidNMFMatch.kr(DelayN.ar(sound,delaytime: ((17-1)*256)/44100), ~bases, maxComponents:8, hopSize:256, fftSize:2048));
	Out.ar(0,perc.dup)
}.play;
)

// make an array of resonators tuned on the median of the centroids
(
8.do({
	arg i;
	{
		var audio = BPF.ar(In.ar(~splitaudio,1), ~centroids[i],0.0015,Lag.kr(In.kr(~nmfenvs,8)[i] * 2,0.022));
		Out.ar(0,Pan2.ar(audio, (i / 14) - 0.25));
	}.play(x,addAction: \addAfter);
});
)
::
