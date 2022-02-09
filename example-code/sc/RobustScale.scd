code::
s.boot;
//Preliminaries: we want some audio, a couple of FluidDataSets, some Buffers and a FluidRobustScale
(
~audiofile = FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav");
~raw = FluidDataSet(s);
~scaled = FluidDataSet(s);
~pitch_feature = Buffer.new(s);
~stats = Buffer.alloc(s, 7, 2);
~robust = FluidRobustScale(s);
)

// Load audio and run a pitch analysis, which gives us pitch and pitch confidence (so a 2D datum)
(
~audio = Buffer.read(s,~audiofile);
FluidBufPitch.process(s,~audio, features: ~pitch_feature);
)

// Divide the time series in to 10, and take the mean of each segment and add this as a point to
// the 'raw' FluidDataSet
(
{
	var trig = LocalIn.kr(1, 1);
	var buf =  LocalBuf(2, 1);
    var count = PulseCount.kr(trig) - 1;
	var chunkLen = (~pitch_feature.numFrames / 10).asInteger;
	var stats = FluidBufStats.kr(
		source: ~pitch_feature, startFrame: count * chunkLen,
        numFrames: chunkLen, stats: ~stats, trig: (trig * (count <=9)), blocking:1
	);
	var rd = BufRd.kr(2, ~stats, DC.kr(0), 0, 1);// pick only mean pitch and confidence
	var wr1 = BufWr.kr(rd[0], buf, DC.kr(0));
	var wr2 = BufWr.kr(rd[1], buf, DC.kr(1));
	var dsWr = FluidDataSetWr.kr(~raw, buf: buf, idNumber: count, trig: Done.kr(stats));
	LocalOut.kr( Done.kr(dsWr));
    Poll.kr(trig,count,\count);
	FreeSelf.kr(count - 9);
}.play;
)

//check the dataset
~raw.print;

// Scale and load to language-side array
(
~rawarray = Array.new(10);
~scaledarray= Array.new(10);
~robust.fitTransform(~raw,~scaled, {
	~raw.dump{|x| 10.do{|i|
		~rawarray.add(x["data"][i.asString])
	}};
	~scaled.dump{|x| 10.do{|i|
		~scaledarray.add(x["data"][i.asString])
	}};
});
)

//Plot side by side. Before normalization the two dimensions have radically different scales
//which can be unhelpful in many cases

(
(~rawarray ++ 0).flop.plot("Raw Data",Rect(0,0,400,400),minval:0,maxval:[5000,1]).plotMode=\bars;
(~scaledarray  ++ 0).flop.plot("Scaled",Rect(410,0,400,400), minval:-2,maxval:2).plotMode=\bars;
)

// single point transform on arbitrary value
~inbuf = Buffer.loadCollection(s,0.5.dup);
~outbuf = Buffer.new(s);
~robust.transformPoint(~inbuf,~outbuf,{|x|x.postln;x.getn(0,2,{|y|y.postln;};)});

//Server side queries
(
{
	var audio = BufRd.ar(1,~audio,LFSaw.ar(BufDur.ir(~audio).reciprocal).range(0, BufFrames.ir(~audio)));
	var counter = Stepper.ar(Impulse.ar(ControlRate.ir),max:99);
    var trig = A2K.kr(HPZ1.ar(counter) < 0);
	//average 100 frames: one could use the MovingAverage extension here
	var avg;
    var inputPoint = LocalBuf(2);
    var outputPoint = LocalBuf(2);
    var avgBuf = LocalBuf(100,2);
    //running average of pitch features
	BufWr.kr(FluidPitch.kr(audio),avgBuf,phase:counter);
	avg = Mix.new(BufRd.kr(2, avgBuf, phase:100.collect{|x|x})) * 0.01;
	//assemble data point
	BufWr.kr(avg[0],inputPoint,0);
	BufWr.kr(avg[1],inputPoint,1);
    ~robust.kr(trig,inputPoint,outputPoint);
	Poll.kr(trig,BufRd.kr(1,inputPoint,[0,1]),["pitch (raw)", "confidence (raw)"]);
    Poll.kr(trig,BufRd.kr(1,outputPoint,[0,1]),["pitch (scaled)", "confidence (scaled)"])
}.play;
)
::
