
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));

(
~transients = Buffer(s);
~residual = Buffer(s);
FluidBufTransients.processBlocking(s,~src,transients:~transients,residual:~residual,action:{
	"done".postln;
});
)

// only transients
(
{
	var sig = PlayBuf.ar(1,~transients,BufRateScale.ir(~transients),doneAction:2);
	sig.dup;
}.play;
)

// juicy clicks
(
{
	var sig = PlayBuf.ar(1,~transients,BufRateScale.ir(~transients) * 6,doneAction:2);
	sig.dup;
}.play;
)

// transients removed
(
{
	var sig = PlayBuf.ar(1,~residual,BufRateScale.ir(~residual),doneAction:2);
	sig.dup;
}.play;
)
::
strong::Comparing the source to the outputs::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"),0,44100 * 2);

(
~transients = Buffer(s);
~residual = Buffer(s);
~compare = Buffer(s);
FluidBufTransients.processBlocking(s,~src,transients:~transients,residual:~residual,order:30,threshFwd:1);
FluidBufCompose.processBlocking(s,~src,destination:~compare,destStartChan:0);
FluidBufCompose.processBlocking(s,~transients,destination:~compare,destStartChan:1);
FluidBufCompose.processBlocking(s,~residual,destination:~compare,destStartChan:2);
FluidWaveform(~compare,bounds:Rect(0,0,1600,1200));
)
::