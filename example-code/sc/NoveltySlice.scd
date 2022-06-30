code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-FMTriDist-M.wav"));

(
{
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var slicer = FluidNoveltySlice.ar(sig,threshold:0.61);
	sig = DelayN.ar(sig,0.1,1024*SampleDur.ir); // compensate for latency
	[sig,slicer];
}.play;
)

::
strong::Tweaking Parameters::
code::

~src = Buffer.read(s,FluidFilesPath("Constanzo-PreparedSnare-M.wav"));

(
~synth = {
	arg kernelSize = 3, threshold = 0.8, minSliceLength = 2, windowSize = 1024;
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var slicer = FluidNoveltySlice.ar(sig,0,kernelSize,threshold,1,minSliceLength,windowSize,maxKernelSize:41);
	sig = DelayN.ar(sig,0.1,windowSize*SampleDur.ir); // compensate for latency
	[sig,slicer];
}.play;
)

// try some different params
~synth.set(\kernelSize,5,\threshold,0.61,\minSliceLength,3);
~synth.set(\kernelSize,41,\threshold,0.35,\minSliceLength,1);
~synth.set(\kernelSize,3,\threshold,0.5,\minSliceLength,1);

::