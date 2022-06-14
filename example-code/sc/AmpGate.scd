strong::Watch the gate::
code::

// make sure the third bus is only output.
(
s.options.numOutputBusChannels_(4);
s.options.numInputBusChannels_(4);
s.reboot;
)

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
{
	var source = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var env = FluidAmpGate.ar(source, rampUp:441, rampDown:2205, onThreshold:-27, offThreshold: -31, minSilenceLength:4410, lookBack:441, highPassFreq:20).poll;
	var sig = DelayN.ar(source,delaytime:441/44100) * env.lag(0.02); // compenstate for latency.
	[sig,sig,env];
}.scope;
)

::
strong::Use for manipulating FX::
code::

~src = Buffer.read(s,FluidFilesPath("Harker-DS-TenOboeMultiphonics-M.wav"));

(
{
	arg thresh = -35;
	var src = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var localbuf = LocalBuf(s.sampleRate).clear;
	var gate = FluidAmpGate.ar(src,10,10,thresh,thresh-5,441,441,441,441).poll;
	var phs = Phasor.ar(0,1 * gate,0,localbuf.numFrames/2); // only write into the buffer when the gate is open
	var trig = Dust.kr(50) * (1-gate); // only trigger grains from that buffer when the gate is closed
	var dur = 0.1;
	var pos = ((phs + localbuf.numFrames/2) - TRand.kr(dur*SampleRate.ir,localbuf.numFrames/2)) / localbuf.numFrames;
	var sig = GrainBuf.ar(2,trig,dur,localbuf,1,pos,4,TChoose.kr(trig,[-0.9,0.9]),mul:6.dbamp);
	BufWr.ar(src,localbuf,[phs,phs+(localbuf.numFrames/2)]);
	sig + src;
}.scope;
)

::