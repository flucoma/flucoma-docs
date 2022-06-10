
CODE::

~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));

// hear the basic parameters: transients in the L channel, residual in the R channel
(
{
	FluidTransients.ar(PlayBuf.ar(1, ~src, loop:1));
}.play
)

// tweaking parameters: listen while adjusting order and skew
(
{
	var sig = PlayBuf.ar(1, ~src, loop:1);
	var order = MouseX.kr(10,80).poll(label:"order");
	var skew = MouseY.kr(-10,10).poll(label:"skew");
	FluidTransients.ar(sig,order,skew:skew)[0].dup
}.play;
)

::
strong::adding some FX::
code::
(
{
	var sig = PlayBuf.ar(1, ~src, loop:1);
	var transients, residual;
	# transients, residual = FluidTransients.ar(sig);
	transients = Pan2.ar(transients,TRand.ar(-1.0,1.0,transients),8.dbamp);
	transients = AllpassC.ar(transients,30.reciprocal,TRand.ar(100.reciprocal,30.reciprocal,transients),8);
	sig = residual.dup + transients;
	sig;
}.play
)
::
strong::The transients and residual null-sum::
code::

// null test (the process adds a latency of ((blockSize + padding) - order) samples)
// this should be silent!
(
{
	var sig = PlayBuf.ar(1, ~src, loop:1);
	var transients, residual, summed;
	var order = 20; // this is the default
	var blockSize = 256; // this is the default
	var padSize = 128; // this is the default;
	# transients, residual = FluidTransients.ar(sig,order,blockSize,padSize);
	summed = [transients, residual].sum;
	sig = DelayN.ar(sig, 1, ((blockSize + padSize) - order) * SampleDur.ir);
	sig - summed;
}.play
)
::
