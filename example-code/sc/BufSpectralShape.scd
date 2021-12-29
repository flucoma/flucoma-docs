
code::
// create some buffers
(
b = Buffer.read(s,File.realpath(FluidBufSpectralShape.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Nicol-LoopE-M.wav");
c = Buffer.new(s);
)

// run the process with basic parameters
(
Routine{
	t = Main.elapsedTime;
	FluidBufSpectralShape.process(s, b, features: c).wait;
	(Main.elapsedTime - t).postln;
}.play
)

// listen to the source and look at the buffer
b.play;
c.plot(separately:true)
::

STRONG::A stereo buffer example.::
CODE::

// load two very different files
(
b = Buffer.read(s,File.realpath(FluidBufSpectralShape.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-SA-UprightPianoPedalWide.wav");
c = Buffer.read(s,File.realpath(FluidBufSpectralShape.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-AcousticStrums-M.wav");
)

// composite one on left one on right as test signals
FluidBufCompose.process(s, c, numFrames:b.numFrames, startFrame:555000,destStartChan:1, destination:b)
b.play

// create a buffer as destinations
c = Buffer.new(s);

//run the process on them
(
Routine{
    t = Main.elapsedTime;
    FluidBufSpectralShape.process(s, b, features: c).wait;
    (Main.elapsedTime - t).postln;
}.play
)

// look at the buffer: 7shapes for left, then 7 shapes for right
c.plot(separately:true)
::
