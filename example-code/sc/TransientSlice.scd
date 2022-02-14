
CODE::
//load some sounds
b = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));

// basic param (the process add a latency of (blockSize + padSize - order) samples
{var sig = PlayBuf.ar(1,b,loop:1); [FluidTransientSlice.ar(sig) * 0.5, DelayN.ar(sig, 1, ((256 + 128 - 20)/ s.sampleRate))]}.play

// other parameters
{var sig = PlayBuf.ar(1,b,loop:1); [FluidTransientSlice.ar(sig,order:80,minSliceLength:2205) * 0.5, DelayN.ar(sig, 1, ((256 + 128 - 80)/ s.sampleRate))]}.play

// More musical, transient-trigged autopan
(
{
	var sig, trig, syncd, pan;
	sig = PlayBuf.ar(1,b,loop:1);
	trig = FluidTransientSlice.ar(sig,order:10,minSliceLength:4410);
	syncd = DelayN.ar(sig, 1, ((256 + 128 - 20)/ s.sampleRate));
	pan = TRand.ar(-1,1,trig);
	Pan2.ar(syncd,pan);
}.play
)
::
