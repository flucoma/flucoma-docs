STRONG::A didactic example::
CODE::
(
// create buffers
b = Buffer.alloc(s,44100);
c = Buffer.alloc(s, 44100);
d = Buffer.new(s);
e = Buffer.new(s);
f = Buffer.new(s);
g = Buffer.new(s);
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
	FluidBufNMF.process(s, d, resynth:e, bases: f, activations:g, components:2).wait;
	e.query;
	f.query;
	g.query;
}.play
)

// look at the resynthesised separated components as audio
e.plot;

// look at the bases signal for 2 spikes
f.plot;

// look at the activations
g.plot;

//trying running the same process on superimposed sinewaves instead of consecutive in the source and see how it fails.
::

STRONG::Basic musical examples::

code::
// set some buffers and parameters
(
b = Buffer.read(s,File.realpath(FluidBufNMF.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-SynthTwoVoices-M.wav");
c = Buffer.new(s);
x = Buffer.new(s);
y = Buffer.new(s);
~fft_size = 1024;
~frame_size = 512;
~hop_size = 256;
~which_component = 4;
)

// matrix factorisation, requesting everything - wait for the computation time to appear.
(
Routine{
	var t = Main.elapsedTime;
    FluidBufNMF.process(s,b, 0,-1,0,-1,c,x,0,y,0,5,100,~frame_size,~hop_size,~fft_size)
    .wait;
     (Main.elapsedTime - t).postln;
}.play
)

//look at the resynthesised components, the bases and the activations
c.plot; x.plot; y.plot;

// play the components spread in the stereo field
{Splay.ar(PlayBuf.ar(5,c,doneAction:2))}.play

//play a single source
{PlayBuf.ar(5,c,doneAction:2)[~which_component].dup}.play

//null test of the sum of sources
{(PlayBuf.ar(5,c,doneAction:2).sum)+(-1*PlayBuf.ar(1,b,doneAction:2))}.play

//play noise using one of the bases as filter.
(
{
	var chain;
	chain = FFT(LocalBuf(~fft_size), WhiteNoise.ar());

	chain = chain.pvcollect(~fft_size, {|mag, phase, index|
		[mag * BufRd.kr(5,x,DC.kr(index),0,1)[~which_component]];
	});

	IFFT(chain);
}.play
)

//play noise using one of the activations as envelope.
{WhiteNoise.ar(BufRd.kr(5,y,Phasor.ar(1,1/~hop_size,0,(b.numFrames / ~hop_size + 1)),0,1)[~which_component])*0.5}.play

//play noise through both matching activation and filter
(
{
	var chain;
	chain = FFT(LocalBuf(~fft_size), WhiteNoise.ar(BufRd.kr(5,y,Phasor.ar(1,1/~hop_size,0,(b.numFrames / ~hop_size + 1)),0,1)[~which_component]*12),0.5,1);

	chain = chain.pvcollect(~fft_size, {|mag, phase, index|
		[mag * BufRd.kr(5,x,DC.kr(index),0,1)[~which_component]];
	});

	[0,IFFT(chain)];
}.play
)

::
STRONG::Fixed Bases: The process can be trained, and the learnt bases or activations can be used as templates.::

CODE::

//set some buffers
(
b = Buffer.read(s,File.realpath(FluidBufNMF.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-AcousticStrums-M.wav");

~originalNMF = Buffer.new(s);
~bases = Buffer.new(s);
~trainedBases = Buffer.new(s);
~activations = Buffer.new(s);
~final = Buffer.new(s);
~spectralshapes  = Buffer.new(s);
~stats  = Buffer.new(s);
~sortedNMF = Buffer.new(s);
)

b.play

// train using the first 2 seconds of the sound file
(
Routine {
	FluidBufNMF.process(s,b,0,44100*5,0,1, ~originalNMF, ~bases, components:10).wait;
	~originalNMF.query;
}.play;
)

// listen to the 10 components across the stereo image
{Splay.ar(PlayBuf.ar(10, ~originalNMF))}.play

// plot the bases
~bases.plot

// find the component that has the picking sound checking the median spectral centroid
(
FluidBufSpectralShape.process(s, ~originalNMF, features: ~spectralshapes, action:{
	|shapes|FluidBufStats.process(s,shapes,stats:~stats, action:{
		|stats|stats.getn(0, (stats.numChannels * stats.numFrames) ,{
			|x| ~centroids = x.select({
				|item, index| (index.mod(7) == 0) && (index.div(70) == 5);
			})
		})
	})
});
)

//what is happening there? We run the spectralshapes on the buffer of 10 components from the nmf. See the structure of that buffer:
~originalNMF.query
//10 channel are therefore giving 70 channels: the 7 shapes of component0, then 7 shapes of compoenent1, etc
~spectralshapes.query
// we then run the bufstats on them. Each channel, which had a time series (an envelop) of each descriptor, is reduced to 7 frames
~stats.query
// we then need to retrieve the values that are where we want: the first of every 7 for the centroid, and the 6th frame of them as we want the median. Because we retrieve the values in an interleave format, the select function gets a bit tricky but we get the following values:
~centroids.postln

// we then copy the basis with the highest median centroid to a channel, and all the other bases to the other channel, of a 2-channel bases for decomposition
(
z = (0..9);
[z.removeAt(~centroids.maxIndex)].do{|chan|FluidBufCompose.process(s, ~bases, startChan: chan, numChans: 1, destination: ~trainedBases, destGain:1)};
z.postln;
z.do({|chan| FluidBufCompose.process(s, ~bases, startChan:chan, numChans: 1, destStartChan: 1, destination: ~trainedBases, destGain:1)});
)
~trainedBases.plot

//process the whole file, splitting it with the 2 trained bases
(
Routine{
	FluidBufNMF.process(s, b, resynth: ~sortedNMF, bases: ~trainedBases, basesMode: 2, components:2).wait;
	~originalNMF.query;
}.play;
)

// play the result: pick on the left, sustain on the right!
{PlayBuf.ar(2,~sortedNMF)}.play

// it even null-sums
{(PlayBuf.ar(2,~sortedNMF,doneAction:2).sum)-(PlayBuf.ar(1,b,doneAction:2))}.play
::

STRONG::Updating Bases: The process can update bases provided as seed.::

CODE::
(
// create buffers
b = Buffer.alloc(s,44100);
c = Buffer.alloc(s, 44100);
d = Buffer.new(s);
e = Buffer.alloc(s,513,3);
f = Buffer.new(s);
g = Buffer.new(s);
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
//make a seeding basis of 3 components:
var highpass, lowpass, direct;
highpass = Array.fill(513,{|i| (i < 50).asInteger});
lowpass = 1 - highpass;
direct = Array.fill(513,0.1);
e.setn(0,[highpass, lowpass, direct].flop.flat);
)

//check the basis: a steep lowpass, a steep highpass, and a small DC
e.plot
e.query

(
// use the seeding basis, without updating
Routine {
	FluidBufNMF.process(s, d, resynth:f, bases: e, basesMode: 2, activations:g, components:3).wait;
	e.query;
	f.query;
	g.query;
}.play
)

// look at the resynthesised separated signal
f.plot;

// look at the bases that have not changed
e.plot;

// look at the activations
g.plot;

(
// use the seeding bases, with updating this time
Routine {
	FluidBufNMF.process(s, d, resynth:f, bases: e, basesMode: 1, activations:g, components:3).wait;
	e.query;
	f.query;
	g.query;
}.play
)

// look at the resynthesised separated signal
f.plot;

// look at the bases that have now updated in place (with the 3rd channel being more focused
e.plot;

// look at the activations (sharper 3rd component at transitions)
g.plot;
::
