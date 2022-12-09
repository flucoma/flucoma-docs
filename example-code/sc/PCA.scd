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
~ds2stan = FluidDataSet(s);
~ds2st2d = FluidDataSet(s);
~ds2st_2d_n = FluidDataSet(s);
)

// first standardize our DataSet, so that the MFCC dimensions are in similar ranges
// then apply the PCA in-place on the standardized data,
// reducing the number of dimensions to the default of 2
// lastly normalize it so it can be plotted in a normalized space
(
~stand = FluidStandardize(s).fitTransform(~ds,~ds2stan);
~pca = FluidPCA(s).fitTransform(~ds2stan,~ds2st2d);
~norm = FluidNormalize(s).fitTransform(~ds2st2d,~ds2st_2d_n);
~ds2st_2d_n.dump({
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
strong::Whitening::
code::

// without whitening (left plot), principal component 1 (x axis) clearly has a longer variance,
// as it should, than principal component 2 (y axis). with whitening, both PCs have unit variance.
// (both plots have the same ranges for their axes). because of this change in relative *scale* the
// distances used to compute the clusters will be different, and will very likely end up with different
// clusters! (run it a few times to see the varieties)

~src = Buffer.readChannel(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"),channels:[0]);

// load analyses into a dataset
(
~analysis = Buffer(s);
FluidBufSpectralShape.processBlocking(s,~src,features:~analysis);
// FluidBufMFCC.processBlocking(s,~src,startCoeff:1,features:~analysis);
~ds = FluidDataSet(s).fromBuffer(~analysis);
~ds.print;

~stand = FluidStandardize(s).fitTransform(~ds,~ds); // note: standardize in place

~ds_pca = FluidDataSet(s);
~pca = FluidPCA(s).fitTransform(~ds,~ds_pca);
~ls = FluidLabelSet(s);
FluidKMeans(s,4).fitPredict(~ds_pca,~ls);

~ds_pca_white = FluidDataSet(s);
~pca_white = FluidPCA(s,whiten:1).fitTransform(~ds,~ds_pca_white);
~ls_white = FluidLabelSet(s);
FluidKMeans(s,4).fitPredict(~ds_pca_white,~ls_white);

~norm = FluidNormalize(s).fit(~ds_pca);
~norm_white = FluidNormalize(s).fit(~ds_pca_white);

~ds_pca.dump({
	arg dict;
	~ds_pca_white.dump({
		arg dict_white;
		~ls.dump({
			arg labels;
			~ls_white.dump({
				arg labels_white;
				~norm.dump({
					arg norm;
					~norm_white.dump({
						arg norm_white;
						var min = min(norm["data_min"].minItem,norm_white["data_min"].minItem);
						var max = max(norm["data_max"].maxItem,norm_white["data_max"].maxItem);

						defer{
							var win = Window(bounds:Rect(0,0,1000,500));
							win.layout_(
								HLayout(
									FluidPlotter(dict:dict,xmin:min,xmax:max,ymin:min,ymax:max,standalone:false).categories_(labels),
									FluidPlotter(dict:dict_white,xmin:min,xmax:max,ymin:min,ymax:max,standalone:false).categories_(labels_white)
								)
							);
							win.front;
						};
					});
				});
			});
		});
	});
});
)
::
