code::
s.boot;

~src = Buffer.read(s,FluidFilesPath("Tremblay-UW-ComplexDescent-M.wav"));

// standardize a spectral analysis
(
~select = [\centroid,\skewness];
~features = Buffer(s);
FluidBufSpectralShape.processBlocking(s,~src,features:~features,select:~select);
~ds = FluidDataSet(s).fromBuffer(~features);
"Firs the Raw Data, then the Standardized Data:".postln;
~ds.print;
~stand = FluidStandardize(s).fitTransform(~ds,~ds);
~ds.print;
~norm = FluidNormalize(s).fitTransform(~ds,~ds); // normalize just for plotting
~ds.dump({
	arg dict;
	defer{FluidPlotter(dict:dict)}
});
)
::
strong::Server-side Querying::
code::

(
{
	var src = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var inputPoint = LocalBuf(2);
	var outputPoint = LocalBuf(2);
	var analysis = FluidSpectralShape.kr(src,~select);
	var standardized, sig;

	analysis.poll(label:"Raw Analysis");
	FluidKrToBuf.kr(analysis,inputPoint);
	~stand.kr(Impulse.kr(100),inputPoint,outputPoint);
	standardized = FluidBufToKr.kr(outputPoint);
	standardized.poll(label:"Standardized Analysis");

	sig = PitchShift.ar(src,0.2,(standardized * [-5,1]).midiratio,standardized.reverse.abs.midiratio);
	sig;
}.play;
)
::
