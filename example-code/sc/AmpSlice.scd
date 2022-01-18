
code::
// detrending explained
// Our source here is a sinewave that does not go to silence and has sharp-ish amplitude bumps as onsets we try to track
(
{
            var env, source = SinOsc.ar(320,0,LFSaw.ar(20, 0, -0.4, 0.6));
	env = FluidAmpSlice.ar(source,fastRampUp: 5,fastRampDown: 50,slowRampUp: 220,slowRampDown: 220, onThreshold: 10, offThreshold: 10,floor: -60);
	[source, env]
}.plot(0.08);
)
//beware of double trigger at the begining of the 2nd cycle above). A solution: Schmidth triggers
(
{var env, source = SinOsc.ar(320,0,LFSaw.ar(20, 0, -0.4, 0.6));
	env = FluidAmpSlice.ar(source,fastRampUp: 5,fastRampDown: 50,slowRampUp: 220,slowRampDown: 220, onThreshold: 10, offThreshold: 7,floor: -60);
	[source, env]
}.plot(0.08);
)
// another solution: minslicelength
(
{var env, source = SinOsc.ar(320,0,LFSaw.ar(20, 0, -0.4, 0.6));
	env = FluidAmpSlice.ar(source,fastRampUp: 5,fastRampDown: 50,slowRampUp: 220,slowRampDown: 220, onThreshold: 10, offThreshold: 7,floor: -60, minSliceLength: 441);
	[source, env]
}.plot(0.08);
)
//quick drum onsets
//load a buffer
b = Buffer.read(s,File.realpath(FluidAmpSlice.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Nicol-LoopE-M.wav");
(
{var env, source = PlayBuf.ar(1,b);
				env = FluidAmpSlice.ar(source,fastRampUp: 10,fastRampDown: 2205,slowRampUp: 4410,slowRampDown: 4410,onThreshold: 10,offThreshold: 5,floor: -40,minSliceLength: 4410,highPassFreq: 20);
	[source, env]
}.play;
)
::
