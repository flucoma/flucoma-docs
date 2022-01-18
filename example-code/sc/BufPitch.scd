
code::
// create a buffer with a short clicking sinusoidal burst (220Hz) starting at frame 8192 for 1024 frames
(
b = Buffer.sendCollection(s, (Array.fill(8192,{0}) ++ (Signal.sineFill(1203,[0,0,0,0,0,1],[0,0,0,0,0,0.5pi]).takeThese({|x,i|i>1023})) ++ Array.fill(8192,{0})));
c = Buffer.new(s);
)

// listen to the source and look at the buffer
b.play; b.plot;

// run the process with basic parameters
(
Routine{
	t = Main.elapsedTime;
	FluidBufPitch.process(s, b, features: c).wait;
	(Main.elapsedTime - t).postln;
}.play
)

// look at the analysis
c.plot(separately:true)

// The values are interleaved [pitch,confidence] in the buffer as they are on 2 channels: to get to the right frame, divide the SR of the input by the hopSize, then multiply by 2 because of the channel interleaving
// here we are querying from one frame before (the signal starts at 8192, which is frame 16 (8192/512), therefore starting the query at frame 15, which is index 30.
c.getn(30,10,{|x|x.postln})

// observe that the first frame is silent, as expected. The next frame's confidence is low-ish, because the window is half full (window of 1024, overlap of 512). Then a full window is analysed, with strong confidence. Then another half full window, then silence, as expected.
::

STRONG::A stereo buffer example.::
CODE::

// load two very different files
(
b = Buffer.read(s,File.realpath(FluidBufPitch.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-SA-UprightPianoPedalWide.wav");
c = Buffer.read(s,File.realpath(FluidBufPitch.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-AcousticStrums-M.wav");
)

// composite one on left one on right as test signals
FluidBufCompose.process(s, c, numFrames:b.numFrames, startFrame:555000,destStartChan:1, destination:b)
b.play

// create a buffer as destinations
c = Buffer.new(s);

//run the process on them, with limited bandwidth and units in MIDI notes
(
Routine{
    t = Main.elapsedTime;
    FluidBufPitch.process(s, b, features: c, minFreq:200, maxFreq:2000, unit:1).wait;
    (Main.elapsedTime - t).postln;
}.play
)

// look at the buffer: [pitch,confidence] for left then [pitch,confidence] for right
c.plot(separately:true)
::

STRONG::A musical example.::
code::
// create some buffers
(
b = Buffer.read(s,File.realpath(FluidBufPitch.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-ASWINE-ScratchySynth-M.wav");
c = Buffer.new(s);
)

// run the process with basic parameters and retrieve the array in the langage side
(
Routine{
	t = Main.elapsedTime;
	FluidBufPitch.process(s, b, features: c,action:{c.loadToFloatArray(action: {|x| d = x.reshape((x.size()/2).asInteger, 2)})}).wait;
	(Main.elapsedTime - t).postln;
}.play
)

//look at the retrieved formatted array of [pitch,confidence] values
d.postln

//iterate and make an array of the indices which are fitting the conditions
(
e = Array.new;
d.do({
	arg val, i;
	if ((val[0] > 500) && (val[1] > 0.98)) {e = e.add(i)}; // if pitch is greater than 500Hz and confidence higher than 0.98, keep the index
});
)
e.postln;

//granulate only the frames that are in our buffer
// We need to convert our indices to frame start. Their position was (index * hopSize) - (hopSize) in FluidBufPitch
f = e.collect({arg i; (i * 512) - 512});

// define a basic grain synth
(
SynthDef(\grain,
    { arg out=0, buf =0 , ind = 0, pan = 0;
        var env;
		env = EnvGen.kr(Env.new([0,1,0],[512/s.sampleRate].dup,\sine), doneAction: Done.freeSelf);
		Out.ar(out, Pan2.ar(PlayBuf.ar(1,buf,startPos:ind),pan));
    }).add;
)

// start the sequence
(
a = Pxrand(f, inf).asStream;
Routine({
    loop({
        Synth(\grain, [\buf, b, \ind, a.next, \pan, (2.0.rand - 1)]);
		(256/s.sampleRate).wait;
    })
}).play;
)
::
