
CODE::
//load a soundfile to play
b = Buffer.read(s,File.realpath(FluidHPSS.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-SynthTwoVoices-M.wav");

// run with basic parameters (left is harmonic, right is percussive)
{FluidHPSS.ar(PlayBuf.ar(1,b,loop:1))}.play

// run in mode 1
{FluidHPSS.ar(PlayBuf.ar(1,b,loop:1),17,51,1,0.05,40,0.1,-40)}.play

// run in mode 2, listening to:
//the harmonic stream
{FluidHPSS.ar(PlayBuf.ar(1,b,loop:1),15,31,2,0.05,40,0.1,-40, 0.1, -10, 0.2, 10)[0].dup}.play
// the percussive stream
{FluidHPSS.ar(PlayBuf.ar(1,b,loop:1),15,31,2,0.05,40,0.1,-40, 0.1, -10, 0.2, 10)[1].dup}.play
// the residual stream
{FluidHPSS.ar(PlayBuf.ar(1,b,loop:1),15,31,2,0.05,40,0.1,-40, 0.1, -10, 0.2, 10)[2].dup}.play

// null test (the process add a latency of ((harmFilterSize - 1) * hopSize) + windowSize) samples
	{var sig = PlayBuf.ar(1,b,loop:1); [FluidHPSS.ar(sig, 17, 31).sum - DelayN.ar(sig, 1, ((((17 - 1) *  512) + 1024) / s.sampleRate))]}.play
::
