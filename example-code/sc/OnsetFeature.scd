code::
~src = Buffer.readChannel(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"),channels:[0]);

(
{
	var sig = PlayBuf.ar(~src.numChannels,~src,BufRateScale.ir(~src),loop:1);
	var feature = FluidOnsetFeature.kr(sig,9,filterSize:5,windowSize:512);
	SendReply.kr(Impulse.kr(30),"/feature",feature);
	sig.dup;
}.play;

OSCdef(\feature,{
	arg msg;
	{"*".post} ! (msg[3] * 1000).abs;
	"".postln;
},"/feature");
)

::
strong::Make your own threshold and Schmidt Trigger::
code::

~src = Buffer.readChannel(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"),channels:[0]);

(
{
	var sig = PlayBuf.ar(~src.numChannels,~src,BufRateScale.ir(~src),loop:1);
	var feature = FluidOnsetFeature.kr(sig,9);
	var trig = Schmidt.kr(feature,0.01,0.1);
	SendReply.kr(trig,"/onset");
	sig;
}.play;

OSCdef(\onset,{
	arg msg;
	"onset".postln;
},"/onset");
)
::