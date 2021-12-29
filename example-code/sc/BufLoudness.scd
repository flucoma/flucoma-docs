
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
	FluidBufLoudness.process(s, source:b, features: c).wait;
	(Main.elapsedTime - t).postln;
}.play
)

// look at the analysis
c.plot(minval:-130, maxval:6)

// The values are interleaved [loudness,truepeak] in the buffer as they are on 2 channels: to get to the right frame, divide the SR of the input by the hopSize, then multiply by 2 because of the channel interleaving
// here we are querying from one frame before (the signal starts at 8192, which is frame 16 (8192/512), therefore starting the query at frame 15, which is index 30.

c.getn(30,10,{|x|x.postln})

// observe that the first frame is silent, as expected. We can appreciate the overshoot of TruePeak of a full range sinewave starting on the second sample (fourth item in the list).
::

STRONG::A stereo buffer example.::
CODE::

// load two very different files
(
b = Buffer.read(s,File.realpath(FluidBufLoudness.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-SA-UprightPianoPedalWide.wav");
c = Buffer.read(s,File.realpath(FluidBufLoudness.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-AcousticStrums-M.wav");
)

// composite one on left one on right as test signals
FluidBufCompose.process(s, c, numFrames:b.numFrames, startFrame:555000,destStartChan:1, destination:b)
b.play

// create a buffer as destinations
c = Buffer.new(s);

//run the process on them with EBU standard Instant Loudness of
(
Routine{
    t = Main.elapsedTime;
    FluidBufLoudness.process(s, b, features: c, windowSize: 17640, hopSize:4410).wait;
    (Main.elapsedTime - t).postln;
}.play
)

// look at the buffer: [loudness,truepeak] for left then [loudness,truepeak] for right
c.plot(minval:-40, maxval:0)
::
