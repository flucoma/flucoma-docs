
code::
//load some sounds
b = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

// basic param (the process add a latency of windowSize samples
{var sig = PlayBuf.ar(1,b,loop:1); [FluidNoveltySlice.ar(sig,0,11,0.33) * 0.5, DelayN.ar(sig, 1, (512 * (((11 + 1) / 2).asInteger + ((1 + 1) / 2).asInteger + 1)) / s.sampleRate, 0.2)]}.play

// other parameters
{var sig = PlayBuf.ar(1,b,loop:1); [FluidNoveltySlice.ar(sig, 1, 31, 0.0035, 4, 100, 128, 32) * 0.5, DelayN.ar(sig, 1, (32 * (((31 + 1)/2).asInteger + ((4 + 1) / 2).asInteger + 1))/ s.sampleRate,0.2)]}.play

// More musical, novelty-trigged autopan
(
{
    var sig, trig, syncd, pan;
    sig = PlayBuf.ar(1,b,loop:1);
    trig = FluidNoveltySlice.ar(sig, 0, 11, 0.25, 5, 1, 128, 32);
    syncd = DelayN.ar(sig, 1, (32 * (((11 + 1)/2).asInteger + ((5 + 1) / 2).asInteger + 1))/ s.sampleRate);
    pan = TRand.ar(-1,1,trig);
    Pan2.ar(syncd,pan);
}.play
)
::
