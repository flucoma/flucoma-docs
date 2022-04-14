code::
~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcBassGuit-Melo-M.wav"));

(
{
	var sig = PlayBuf.ar(~src.numChannels,~src,BufRateScale.ir(~src),loop:1);
	var feature = FluidNoveltyFeature.kr(sig,3,5,1); // feature is pitch and pitch confidence
	SendReply.kr(Impulse.kr(30),"/feature",feature);
	sig.dup;
}.play;

OSCdef(\feature,{
	arg msg;
	{"*".post} ! (msg[3] * 20);
	" %".format(msg[3].round(0.1)).postln;
},"/feature");
)

::
strong::Make your own threshold and Schmidt Trigger::
code::
~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));

(
{
	var sig = PlayBuf.ar(~src.numChannels,~src,BufRateScale.ir(~src),loop:1);
	var feature = FluidNoveltyFeature.kr(sig,1);
	var trig = Schmidt.kr(feature,0.3,0.5);
	SendReply.kr(trig,"/onset");
	sig.dup;
}.play;

OSCdef(\onset,{
	arg msg;
	"onset".postln;
},"/onset");
)
::