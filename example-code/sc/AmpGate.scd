
code::
//basic tests: threshold sanity
(
{var env, source = SinOsc.ar(320,0,LFTri.ar(10).abs);
	env = FluidAmpGate.ar(source, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12);
	[source, env]
}.plot(0.1);
)
//basic tests: threshold hysteresis
(
{var env, source = SinOsc.ar(320,0,LFTri.ar(10).abs);
	env = FluidAmpGate.ar(source, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -16);
	[source, env]
}.plot(0.1);
)
//basic tests: threshold min slice
(
{var env, source = SinOsc.ar(320,0,LFTri.ar(10).abs);
	env = FluidAmpGate.ar(source, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minSliceLength:441);
	[source, env]
}.plot(0.1);
)
//basic tests: threshold min silence
(
{var env, source = SinOsc.ar(320,0,LFTri.ar(10).abs);
	env = FluidAmpGate.ar(source, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minSilenceLength:441);
	[source, env]
}.plot(0.1);
)
//mid tests: threshold time hysteresis on
(
{var env, source = SinOsc.ar(320,0,LFTri.ar(10).abs);
	env = FluidAmpGate.ar(source, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minLengthAbove:441);
	[DelayN.ar(source,0.1,441/44100), env]
}.plot(0.1);
)
//mid tests: threshold time hysteresis off
(
{var env, source = SinOsc.ar(320,0,LFTri.ar(10).abs);
	env = FluidAmpGate.ar(source, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minLengthBelow:441);
	[DelayN.ar(source,0.1,441/44100), env]
}.plot(0.1);
)
//mid tests: threshold with lookBack
(
{var env, source = SinOsc.ar(320,0,LFTri.ar(10).abs);
	env = FluidAmpGate.ar(source, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, lookBack:441);
	[DelayN.ar(source,0.1,441/44100), env]
}.plot(0.1);
)
//mid tests: threshold with lookAhead
(
{var env, source = SinOsc.ar(320,0,LFTri.ar(10).abs);
	env = FluidAmpGate.ar(source, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, lookAhead:441);
	[DelayN.ar(source,0.1,441/44100), env]
}.plot(0.1);
)
//mid tests: threshold with asymetrical lookBack and lookAhead
(
{var env, source = SinOsc.ar(320,0,LFTri.ar(10).abs);
	env = FluidAmpGate.ar(source, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, lookBack:221, lookAhead:441);
	[DelayN.ar(source,0.1,441/44100), env]
}.plot(0.1);
)
//drum slicing, many ways
//load a buffer
b = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));
//have fun with a gate (explore lookahead and lookback, but correct for latency, which will be the greatest of the lookahead and lookback)
(
{var env, source = PlayBuf.ar(1,b);
	env = FluidAmpGate.ar(source, rampUp:441, rampDown:2205, onThreshold:-27, offThreshold: -31, minSilenceLength:4410, lookBack:441, highPassFreq:20);
	[DelayN.ar(source,delaytime:441/44100), env]
}.plot(2, separately:true);
)
::
