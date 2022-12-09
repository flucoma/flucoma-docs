code::
s.boot;

~src = Buffer.read(s,FluidFilesPath("Tremblay-UW-ComplexDescent-M.wav"));

// standardize a spectral analysis
(
~select = [\centroid,\skewness];
~features = Buffer(s);
FluidBufSpectralShape.processBlocking(s,~src,features:~features,select:~select);
~ds = FluidDataSet(s).fromBuffer(~features);
"First the Raw Data, then the Standardized Data:".postln;
~ds.print;
~norm = FluidNormalize(s).fitTransform(~ds,~ds); // normalize (in place) first to match the ranges
~ds.print;
~stand = FluidStandardize(s).fitTransform(~ds,~ds); // standardize then in place again
~ds.print;
~ds.dump({
	arg dict;
	defer{FluidPlotter(dict:dict,xmin: -1, xmax: 1, ymin: -1, ymax: 1)} //plotter range is +/- one standard deviation
});
)

::
strong::Transforming a single point::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-UW-ComplexDescent-M.wav"));

// standardize a spectral analysis
(
~features = Buffer(s);
FluidBufSpectralShape.processBlocking(s,~src,features:~features);
~ds = FluidDataSet(s).fromBuffer(~features);
"Firs the Raw Data, then the Standardized Data:".postln;
~ds.print;
~ds_stand = FluidDataSet(s);
~stand = FluidStandardize(s).fitTransform(~ds,~ds_stand);
~ds_stand.print;
)

~singlePoint = Buffer.alloc(s,7);

// take a look at the original via a bar graph. see post window for extreme differences in scale
(
~ds.getPoint("0",~singlePoint);
~singlePoint.loadToFloatArray(action:{
	arg fa;
	fa.postln;
	defer{fa.plot.plotMode_(\bars)};
});
)

~scaledPoint = Buffer.alloc(s,7);

// now standardize it using the `fit` from above
// see the post window to notice that the ranges are now all similar
(
~stand.transformPoint(~singlePoint,~scaledPoint);
~scaledPoint.loadToFloatArray(action:{
	arg fa;
	fa.postln;
	defer{fa.plot.plotMode_(\bars)};
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
