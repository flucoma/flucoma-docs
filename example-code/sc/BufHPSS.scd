
code::
//load buffers
(
	b = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));
	c = Buffer.new(s);
	d = Buffer.new(s);
	e = Buffer.new(s);
)

// run with basic parameters
(
	Routine{
		t = Main.elapsedTime;
		FluidBufHPSS.process(s, b, harmonic: c, percussive: d).wait;
		(Main.elapsedTime - t).postln;
	}.play
)
c.query
d.query
//play the harmonic
c.play;
//play the percussive
d.play;

//nullsumming tests
{(PlayBuf.ar(1,c))+(PlayBuf.ar(1,d))+(-1*PlayBuf.ar(1,b,doneAction:2))}.play

//more daring parameters, in mode 2
(
Routine{
    t = Main.elapsedTime;
    FluidBufHPSS.process(s, b, harmonic: c, percussive: d, residual:e, harmFilterSize:31, maskingMode:2, harmThreshFreq1: 0.005, harmThreshAmp1: 7.5, harmThreshFreq2: 0.168, harmThreshAmp2: 7.5, percThreshFreq1: 0.004, percThreshAmp1: 26.5, percThreshFreq2: 0.152, percThreshAmp2: 26.5,windowSize:4096,hopSize:512)
    .wait;
    (Main.elapsedTime - t).postln;
}.play
)

//play the harmonic
c.play;
//play the percussive
d.play;
//play the residual
e.play;

//still nullsumming
{PlayBuf.ar(1,c) + PlayBuf.ar(1,d) + PlayBuf.ar(1,e) - PlayBuf.ar(1,b,doneAction:2)}.play;
::

STRONG::A stereo buffer example.::
CODE::

// load two very different files
(
b = Buffer.read(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"));
c = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcousticStrums-M.wav"));
)

// composite one on left one on right as test signals
(
Routine{
    FluidBufCompose.process(s, c, numFrames:b.numFrames, startFrame:555000,destStartChan:1, destination:b).wait;
    b.play
}.play
)
// create 2 new buffers as destinations
d = Buffer.new(s); e = Buffer.new(s);

//run the process on them
(
Routine{
    t = Main.elapsedTime;
    FluidBufHPSS.process(s, b, harmonic: d, percussive:e).wait;
    (Main.elapsedTime - t).postln;
}.play
)

//listen: stereo preserved!
d.play
e.play
::
