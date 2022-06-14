
CODE::
//load some sounds
~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));

// basic param (the process add a latency of (blockSize + padSize - order) samples
(
{
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var order = 20; // this is the default
	var blockSize = 256; // this is the default
	var padSize = 128; // this is the default
	var slice_impulses = FluidTransientSlice.ar(sig,order,blockSize,padSize);
	sig = DelayN.ar(sig, 1, ((blockSize + padSize) - order) * SampleDur.ir); // compute the latency and delay the original signal
	[sig,slice_impulses * -6.dbamp];
}.play
)

// other parameters
(
{
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var order = 80;
	var blockSize = 256; // this is the default
	var padSize = 128; // this is the default
	var slice_impulses = FluidTransientSlice.ar(sig,order,blockSize,padSize,minSliceLength:2205);
	sig = DelayN.ar(sig, 1, ((blockSize + padSize) - order) * SampleDur.ir); // compute the latency and delay the original signal
	[sig,slice_impulses * -6.dbamp];
}.play
)

// More musical, transient-trigged autopan
(
{
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var order = 20; // this is the default
	var blockSize = 256; // this is the default
	var padSize = 128; // this is the default
	var slice_impulses = FluidTransientSlice.ar(sig,order,blockSize,padSize);
	sig = DelayN.ar(sig, 1, ((blockSize + padSize) - order) * SampleDur.ir); // compute the latency and delay the original signal
	Pan2.ar(sig,TRand.ar(-1.0,1.0,slice_impulses).poll);
}.play
)
::
