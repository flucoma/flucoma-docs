
code::
(
b = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));
c = Buffer.new(s);
d = Buffer.new(s);
)

// with basic params
(
Routine{
	t = Main.elapsedTime;
	FluidBufTransients.process(s,b, transients:c, residual:d).wait;
	(Main.elapsedTime - t).postln;
}.play
);

// wait for the duration to appear in the post window as a cue that the computation is finished
c.play;
d.play;

//nullsumming tests
{(PlayBuf.ar(1,c))+(PlayBuf.ar(1,d))+(-1*PlayBuf.ar(1,b,doneAction:2))}.play


// with everything changed to make it much better, at the cost of computation time (only 5 seconds are processed here)
(
Routine{
	t = Main.elapsedTime;
	FluidBufTransients.process(s,b, 0, 220500, 0, 1, c, d, 200, 2048, 1024, 1, 3, 1, 15, 30).wait;
	(Main.elapsedTime - t).postln;
}.play
)

// wait for the duration to appear in the post window as a cue that the computation is finished
c.play;
d.play;
::

STRONG::A stereo buffer example.::
CODE::

// load two very different files
(
b = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));
c = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcousticStrums-M.wav"));
)

// composite one on left one on right as test signals
FluidBufCompose.process(s, c, numFrames:b.numFrames, startFrame:555000, destStartChan:1, destination:b)
b.play

// create 2 new buffers as destinations
d = Buffer.new(s); e = Buffer.new(s);

//run the process on them
(
Routine{
    t = Main.elapsedTime;
    FluidBufTransients.process(s, b, transients: d, residual:e, threshFwd:1.2, clumpLength:40).wait;
    (Main.elapsedTime - t).postln;
}.play
)

//listen: stereo preserved!
d.play
e.play
::
