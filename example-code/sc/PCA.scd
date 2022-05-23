strong::Dimensionality Reduction::
code::

s.boot;

~src = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));

// load MFCC analyses into a dataset
(
~mfcc_feature = Buffer(s);
FluidBufMFCC.processBlocking(s,~src,startCoeff:1,features:~mfcc_feature);
~ds = FluidDataSet(s).fromBuffer(~mfcc_feature);
~ds.print;
)

// first standardize our DataSet, so that the MFCC dimensions are on comensurate scales
// then apply the PCA in-place on the standardized data,
// reducing the number of dimensions to the default of 2
// lastly normalize it so it can be plotted in a normalized space
(
~stand = FluidStandardize(s).fitTransform(~ds,~ds);
~pca = FluidPCA(s).fitTransform(~ds,~ds);
~norm = FluidNormalize(s).fitTransform(~ds,~ds);
~ds.dump({
	arg dict;
	defer{FluidPlotter(dict:dict)};
});
)
::
strong::Server-side queries::
code::
(
{
	var src = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var mfccs = FluidMFCC.kr(src,startCoeff:1);
	var trig = Impulse.kr(30);
    var inputPoint = LocalBuf(13);
	var standPoint = LocalBuf(13);
    var outputPoint = LocalBuf(2);
	var normPoint = LocalBuf(2);
	var sig, pca1, pca2;

	FluidKrToBuf.kr(mfccs,inputPoint);
	~stand.kr(trig,inputPoint,standPoint);
	~pca.kr(trig, standPoint, outputPoint,2);
	~norm.kr(trig,outputPoint,normPoint);

	# pca1, pca2 = FluidBufToKr.kr(normPoint).lag(0.01).poll;

	sig = CombC.ar(src,0.05,[1-pca1,pca2].clip * 0.05,(1-pca1).clip * 3,-16.dbamp) + src;

	sig;
}.play;
)
::
