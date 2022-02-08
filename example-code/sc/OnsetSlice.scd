
code::
//load some sounds
b = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

// basic param (the process add a latency of windowSize samples
{var sig = PlayBuf.ar(1,b,loop:1); [FluidOnsetSlice.ar(sig) * 0.5, DelayN.ar(sig, 1, 1024/ s.sampleRate)]}.play

// other parameters
{var sig = PlayBuf.ar(1,b,loop:1); [FluidOnsetSlice.ar(sig, 9, 0.15, 45, 9, 0, 128, 64) * 0.5, DelayN.ar(sig, 1, (128)/ s.sampleRate)]}.play

// More musical, onset-trigged autopan
(
{
    var sig, trig, syncd, pan;
    sig = PlayBuf.ar(1,b,loop:1);
    trig = FluidOnsetSlice.ar(sig, 7, 0.2, 100, 9, 0, 128);
	syncd = DelayN.ar(sig, 1, (128 / s.sampleRate)); //one could add a bit more delay here to make sure to catch the attack
	pan = Stepper.ar(trig,-1,-1,1,1);
    Pan2.ar(syncd,pan);
}.play
)
::
