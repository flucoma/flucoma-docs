strong::Use the output as a stream of decibels to manipulate another (or the same) audio signal::
code::
~drums = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

// listen to the original
~drums.play;

// add extra pop to the drums by using the AmpFeature envelope
(
{
	var sig = PlayBuf.ar(~drums.numChannels,~drums,BufRateScale.ir(~drums),loop:1);
	var amp_feature = FluidAmpFeature.ar(sig,100,100,44100,44100,-40);
	amp_feature.poll;
	sig * amp_feature.dbamp * -30.dbamp;
}.play;
)

// really suppress the amplitude peaks by inverting the feature
(
{
	var sig = PlayBuf.ar(~drums.numChannels,~drums,BufRateScale.ir(~drums),loop:1);
	var amp_feature = FluidAmpFeature.ar(sig,100,100,44100,44100,-40) * -1;
	amp_feature.poll;
	sig * amp_feature.dbamp
}.play;
)

::
strong::Make your own threshold, similar to how FluidAmpSlice works::
code::

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

// listen to the original
~src.play;

(
{
	var sig = PlayBuf.ar(~src.numChannels,~src,BufRateScale.ir(~src),loop:1);
	var amp_feature = FluidAmpFeature.ar(sig,100,100,44100,44100,-40);
	var trig = Schmidt.ar(amp_feature,0,6);
	SendReply.ar(trig,"/amp_onset");
	sig;
}.play;

OSCdef(\amp_onset,{
	arg msg;
	"onset".postln;
},"/amp_onset");
)
::