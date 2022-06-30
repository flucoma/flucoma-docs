
code::

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
{
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var onsets = FluidOnsetSlice.ar(sig);
	sig = DelayN.ar(sig, 1, 1024 * SampleDur.ir); // compensate for a latency of windowSize samples
	[sig,onsets];
}.play
)

// other parameters
(
{
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var onsets = FluidOnsetSlice.ar(sig,metric:9,threshold:0.15,minSliceLength:45,filterSize:9,frameDelta:0,windowSize:128,hopSize:64);
	sig = DelayN.ar(sig, 1, 128 * SampleDur.ir);
	[sig, onsets]
}.play
)

// More musical, onset-trigged autopan
(
{
    var sig, trig, pan;
	sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
    trig = FluidOnsetSlice.ar(sig,metric:7,threshold:0.2,minSliceLength:100,filterSize:9,frameDelta:0,windowSize:128);
	sig = DelayN.ar(sig, 1, 128 * SampleDur.ir); //one could add a bit more delay here to make sure to catch the attack
	pan = Stepper.ar(trig,-1,-1,1,1);
    Pan2.ar(sig,pan);
}.play
)
::
