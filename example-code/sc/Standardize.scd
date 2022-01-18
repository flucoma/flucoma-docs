code::
s.boot;
//Preliminaries: we want some audio, a couple of FluidDataSets, some Buffers and a FluidStandardize
(
~audiofile = File.realpath(FluidBufPitch.class.filenameSymbol).dirname +/+ "../AudioFiles/Tremblay-ASWINE-ScratchySynth-M.wav";
~raw = FluidDataSet(s);
~stand = FluidDataSet(s);
~audio = Buffer.read(s,~audiofile);
~pitch_feature = Buffer.new(s);
~stats = Buffer.alloc(s, 7, 2);
~standardizer = FluidStandardize(s);
)


// Load audio and run a pitch analysis, which gives us pitch and pitch confidence (so a 2D datum)
(
~audio = Buffer.read(s,~audiofile);
FluidBufPitch.process(s,~audio, features: ~pitch_feature,action:{"Analysed Pitch".postln});
)

// Divide the time series in to 10, and take the mean of each s"egment and add this as a point to
// the 'raw' FluidDataSet
(
{
	var trig = LocalIn.kr(1, 1);
	var buf =  LocalBuf(2, 1);
    var count = PulseCount.kr(trig) - 1;
	var chunkLen = (~pitch_feature.numFrames / 10).asInteger;
	var stats = FluidBufStats.kr(
        source: ~pitch_feature, startFrame: count * chunkLen,
        numFrames: chunkLen, stats: ~stats,
        trig: trig * (count < 10), blocking: 1
	);
	var rd = BufRd.kr(2, ~stats, DC.kr(0), 0, 1);// pick only mean pitch and confidence
	var wr1 = BufWr.kr(rd[0], buf, DC.kr(0));
	var wr2 = BufWr.kr(rd[1], buf, DC.kr(1));
	var dsWr = FluidDataSetWr.kr(~raw, buf: buf, idNumber: count, trig: Done.kr(stats));
	LocalOut.kr( Done.kr(dsWr));
	FreeSelf.kr(count - 9);
    Poll.kr(trig,count, \count);
}.play;
)

// Standardize and load to language-side array
(
~rawarray = Array.new(10);
~stdarray= Array.new(10);
~standardizer.fitTransform(~raw,~stand, {
	~raw.dump{|x| 10.do{|i|
		~rawarray.add(x["data"][i.asString])
	}};
	~stand.dump{|x| 10.do{|i|
		~stdarray.add(x["data"][i.asString])
	}};
});
)

(
(~rawarray ++ 0).flop.plot("Unstandardized",Rect(0,0,400,400),minval:0,maxval:[5000,1]).plotMode=\bars;
(~stdarray  ++ 0).flop.plot("Standardized",Rect(410,0,400,400), minval:-2,maxval:2).plotMode=\bars;
)

// single point transform on arbitrary value
~inbuf = Buffer.loadCollection(s,0.5.dup);
~outbuf = Buffer.new(s);
~standardizer.transformPoint(~inbuf,~outbuf,{|x|x.postln;x.getn(0,2,{|y|y.postln;};)});

::

subsection::Server Side Querying
code::
(
// read frames out of buffer and pass to standardize
{
	var audio = BufRd.ar(1,~audio,LFSaw.ar(BufDur.ir(~audio).reciprocal).range(0, BufFrames.ir(~audio)));
	var counter = Stepper.ar(Impulse.ar(ControlRate.ir),max:99);
    var trig = A2K.kr(HPZ1.ar(counter) < 0);
	//average 10 frames: one could use the MovingAverage extension here
	var avg;
    var inputPoint= LocalBuf(2);
    var outputPoint = LocalBuf(2);
    var avgBuf = LocalBuf(100,2);
    //average of pitch features
	BufWr.kr(FluidPitch.kr(audio),avgBuf,phase:counter);
	avg = Mix.new(BufRd.kr(2, avgBuf, phase:100.collect{|x|x})) * 0.01;
	//assemble data point
	BufWr.kr(avg[0],inputPoint,0);
	BufWr.kr(avg[1],inputPoint,1);
	Poll.kr(trig,BufRd.kr(1,inputPoint,[0,1]),["pitch (raw)", "confidence (raw)"]);
    ~standardizer.kr(trig,inputPoint,outputPoint);
    Poll.kr(trig,BufRd.kr(1,outputPoint,[0,1]),["pitch (standardized)", "confidence (standardized)"]);
}.play;
)
::
