
code::

//Preliminaries: we want some audio, a couple of FluidDataSets, some Buffers, a FluidStandardize and a FluidMDS
(
~audiofile = File.realpath(FluidMDS.class.filenameSymbol).dirname +/+ "../AudioFiles/Tremblay-ASWINE-ScratchySynth-M.wav";
~raw = FluidDataSet(s);
~standardized = FluidDataSet(s);
~reduced = FluidDataSet(s);
~audio = Buffer.read(s,~audiofile);
~mfcc_feature = Buffer.new(s);
~stats = Buffer.alloc(s, 7, 12);
~standardizer  = FluidStandardize(s);
~mds = FluidMDS(s);
)

// Load audio and run an mfcc analysis, which gives us 13 points (we'll throw the 0th away)
(
~audio = Buffer.read(s,~audiofile);
FluidBufMFCC.process(s,~audio, features: ~mfcc_feature);
)

// Divide the time series in 100, and take the mean of each segment and add this as a point to
// the 'raw' FluidDataSet
(
{
	var trig = LocalIn.kr(1, 1);
	var buf =  LocalBuf(12, 1);
    var count = PulseCount.kr(trig) - 1;
	var chunkLen = (~mfcc_feature.numFrames / 100).asInteger;
	var stats = FluidBufStats.kr(
			source: ~mfcc_feature, startFrame: count * chunkLen,
		    startChan:1, numFrames: chunkLen, stats: ~stats, trig: trig, blocking:1
	);
	var rd = BufRd.kr(12, ~stats, DC.kr(0), 0, 1);
	var bufWr, dsWr;
	12.do{|i|
		bufWr = BufWr.kr(rd[i], buf, DC.kr(i));
	};
	dsWr = FluidDataSetWr.kr(~raw, buf: buf, idNumber: count, trig: Done.kr(stats),blocking:1);
    LocalOut.kr(Done.kr(dsWr));
    FreeSelf.kr(count - 99);
	Poll.kr(trig,(100-count));
}.play;
)
// wait for the count to reaches 0 in the post window.

//First standardize our DataSet, so that the MFCC dimensions are on comensurate scales
//Then apply the MDS in-place on the standardized data to get 2 dimensions, using a Euclidean distance metric
//Download the DataSet contents into an array for plotting
(
~reducedarray = Array.new(100);
~standardizer.fitTransform(~raw, ~standardized);
~mds.fitTransform(~standardized, ~reduced, action:{
    ~reduced.dump{|x| 100.do{|i|
        ~reducedarray.add(x["data"][i.asString])
}}});
)

//Visualise the 2D projection of our original 12D data
(
d = ~reducedarray.flop.deepCollect(1, { |x| x.normalize});
w = Window("scatter", Rect(128, 64, 200, 200));
w.drawFunc = {
    Pen.use {
        d[0].size.do{|i|
            var x = (d[0][i]*200);
            var y = (d[1][i]*200);
            var r = Rect(x,y,5,5);
            Pen.fillColor = Color.blue;
            Pen.fillOval(r);
        }
    }
};
w.refresh;
w.front;
)

//we can change the distance computation
~mds.distanceMetric = FluidMDS.kl;

//recompute the reduction and recover the points
(
~reducedarray2 = Array.new(100);
~mds.fitTransform(~standardized, ~reduced, action:{
	~reduced.dump{|x| 100.do{|i|
		~reducedarray2.add(x["data"][i.asString])
     }}});
)

//draw the new projection in red above the other
//Visualise the 2D projection of our original 12D data
(
d = ~reducedarray.flop.deepCollect(1, { |x| x.normalize});
e = ~reducedarray2.flop.deepCollect(1, { |x| x.normalize});
w.drawFunc = {
    Pen.use {
		d[0].size.do{|i|
            var x = (d[0][i]*200);
            var y = (d[1][i]*200);
            var r = Rect(x,y,5,5);
            Pen.fillColor = Color.blue;
            Pen.fillOval(r);
        };
        e[0].size.do{|i|
            var x = (e[0][i]*200);
            var y = (e[1][i]*200);
            var r = Rect(x,y,5,5);
            Pen.fillColor = Color.red;
            Pen.fillOval(r);
        }
    }
};
w.refresh;
w.front;
)
::
