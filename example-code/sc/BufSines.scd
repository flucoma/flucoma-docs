
code::
// create some buffers
(
b = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));
c = Buffer.new(s);
d = Buffer.new(s);
)

// run the process with basic parameters
(
Routine{
	t = Main.elapsedTime;
	FluidBufSines.process(s, b, sines: c, residual:d).wait;
	(Main.elapsedTime - t).postln;
}.play
)

// listen to each component
c.play;
d.play;

//nullsumming tests
{(PlayBuf.ar(1, c)) + (PlayBuf.ar(1,d)) - (PlayBuf.ar(1,b,doneAction:2))}.play
::

STRONG::A stereo buffer example.::
CODE::

// load two very different files
(
b = Buffer.read(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"));
c = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcousticStrums-M.wav"));
)

// composite one on left one on right as test signals
FluidBufCompose.process(s, c, numFrames:b.numFrames, startFrame:555000,destStartChan:1, destination:b)
b.play

// create 2 new buffers as destinations
d = Buffer.new(s); e = Buffer.new(s);

//run the process on them
(
Routine{
    t = Main.elapsedTime;
    FluidBufSines.process(s, b, sines: d, residual:e, windowSize: 2048, hopSize: 256, fftSize: 16384).wait;
    (Main.elapsedTime - t).postln;
}.play
)

//listen: stereo preserved!
d.play
e.play
::
