CODE::

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

//split in various chunks, collecting the indices in an array
(
~indices = Buffer.new(s);
FluidBufOnsetSlice.processBlocking(s,~src,threshold:5,indices:~indices); // find slice points in src buffer
~indices.loadToFloatArray(action:{
	arg fa;
	var features = Buffer(s);
	var stats = Buffer(s);
	var flat = Buffer(s);
	~ds = FluidDataSet(s);
	fa.doAdjacentPairs{ // take in turn, the start and stop point of every slice
		arg start, end, i;
		FluidBufMFCC.processBlocking(s,~src,start,end-start,features:features); // doo the mfcc analysis
		FluidBufStats.processBlocking(s,features,stats:stats); // get the statistical summary of the mfcc analysis
		FluidBufFlatten.processBlocking(s,stats,startFrame:5,numFrames:1,destination:flat); // copy out the median mfcc values into a flattened buffer
		~ds.addPoint("slice-%".format(i),flat); // add those values to the dataset
	};
	~ds.print;
});
)

::
STRONG::Derivative::
CODE::

// this example sorts some tones by the derivative of the pitch analysis
// this provides a sorted order of the tones with the tones that "glissando down" on one end
// and the tones that "glissando up" on the other end

// we'll record into this buffer
~src = Buffer.alloc(s,s.sampleRate*10);

(
// a simple random sliding bell synth,
// let this play for all 10 seconds, as it's recording into a buffer!
{
	var trig = Impulse.ar(1.5);
	var freq = Lag.ar(TRand.ar(trig: trig),TRand.ar(0.5, trig: trig)).exprange(333,666);
	var mul = Decay.ar(trig * TRand.ar(0.1,10,trig),TRand.ar(0.5,1.1,trig));
	var sig = SinOsc.ar(freq,mul:mul).atan * 0.1;
	var env = EnvGen.kr(Env([0,1,1,0],[0.03,~src.duration-0.06,0.03]));
	RecordBuf.ar(sig,~src,loop:0,doneAction:2);
	sig;
}.play;
)

//split in various chunks, collecting the indices in an array
(
~indices = Buffer.new(s);
FluidBufOnsetSlice.processBlocking(s,~src,threshold:0.01,indices:~indices,action:{
	~indices.loadToFloatArray(action:{
		arg array;
		~indices_array = array.add(~src.numFrames);
		"found % slice points: ".format(~indices_array.size).post;
		~indices_array.postln;
	});
});
)

// analyze them for pitch including the first derivative, save the median of the 1st derivative
(
~pitch_analysis = Buffer(s);
~stats = Buffer(s);
~deriv_1_medians = Buffer(s);
~indices_array.doAdjacentPairs{
	arg start, end, i; // get the start and end of each slice

	// analyze that slice for pitch
	FluidBufPitch.processBlocking(s,~src,start,end-start,features:~pitch_analysis);

	// get the stats of the analysis and the stats of the derivative (only channel 1 though, not pitch conf)
	FluidBufStats.processBlocking(s,~pitch_analysis,numChans:1,stats:~stats,numDerivs:1);

	// write the median of the derivative (index 12) into the derivative medians buffer
	FluidBufCompose.processBlocking(s,~stats,startFrame:12,numFrames:1,destination:~deriv_1_medians,destStartFrame:i);
};
~deriv_1_medians.loadToFloatArray(action:{
	arg fa;
	"here are the % median values of derivative 1 of the pitch analysis".format(fa.size).postln;
	fa.postln;
	~sorted_indices = fa.order; // the the indexes in a sorted order
	~sorted_indices.postln;
});
)

//play in loop the slice in order of pitch direction (the median of the slice's pitch variation) - mouse on the left should be descending, in the middle should be more stable, and it should be ascending on the right.
(
Buffer.loadCollection(s,~sorted_indices,action:{
	arg buf;
	{
		var which = MouseX.kr(0,BufFrames.kr(buf)-1).floor;
		var index = Index.kr(buf,which);
		var start = BufRd.kr(1,~indices,index,0,1);
		var end = BufRd.kr(1,~indices,index+1,0,1);
		var phs = Phasor.ar(0,1,start,end);
		BufRd.ar(1,~src,phs);
	}.play;
};)
)

::
STRONG::Weights::
CODE::
// consider trying to extract the pitch from this recording
~src = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"),0,44100 * 6);

~src.play;

// a look at the pitch analysis shows a quite eratic time series
(
~pitch_analysis = Buffer(s);
FluidBufPitch.processBlocking(s,~src,features:~pitch_analysis);
FluidWaveform(~src,featuresBuffer:~pitch_analysis,stackFeatures:true,bounds:Rect(0,0,1600,400));
)

// if one were to take the average pitch from this time series it doesn't sound right;
(
~stats = Buffer(s);
FluidBufStats.processBlocking(s,~pitch_analysis,stats:~stats,numChans:1);
{
	var sig = SinOsc.ar(BufRd.kr(1,~stats,0),0,-20.dbamp);
	var srcsig = PlayBuf.ar(1,~src,BufRateScale.ir(~src));
	var env = EnvGen.kr(Env([0,1,1,0],[0.03,~src.duration-0.06,0.03]),doneAction:2);
	sig = sig + srcsig;
	sig = sig * env;
	sig.dup;
}.play;
)

(
// we'll use the pitch confidence to weight the statistical analysis so our mean will be a weighted mean based on how confident the pitch algorithm is in the pitch it is returning;
~conf = Buffer(s);
FluidBufCompose.processBlocking(s,~pitch_analysis,startChan:1,numChans:1,destination:~conf);
FluidBufStats.processBlocking(s,~pitch_analysis,stats:~stats,weights:~conf);
{
	var sig = SinOsc.ar(BufRd.kr(2,~stats,0)[0],0,-20.dbamp);
	var srcsig = PlayBuf.ar(1,~src,BufRateScale.ir(~src));
	var env = EnvGen.kr(Env([0,1,1,0],[0.03,~src.duration-0.06,0.03]),doneAction:2);
	sig = sig + srcsig;
	sig = sig * env;
	sig.dup;
}.play;
)

// now it's too low, how about we threshold the conf
(
~threshed = Buffer(s);
FluidBufThresh.processBlocking(s,~conf,destination:~threshed,threshold:0.97);
FluidBufStats.processBlocking(s,~pitch_analysis,stats:~stats,weights:~threshed);
{
	var sig = SinOsc.ar(BufRd.kr(2,~stats,0)[0],0,-20.dbamp);
	var srcsig = PlayBuf.ar(1,~src,BufRateScale.ir(~src));
	var env = EnvGen.kr(Env([0,1,1,0],[0.03,~src.duration-0.06,0.03]),doneAction:2);
	sig = sig + srcsig;
	sig = sig * env;
	sig.dup;
}.play;
)
::
STRONG::Outliers::
CODE::

// let's try to find the pitch of this trombone tone
~src = Buffer.read(s,FluidFilesPath("Olencki-TenTromboneLongTones-M.wav"),numFrames:44100*3.3);

~src.play;

// do the pitch analysis
(
~pitch_analysis = Buffer(s);
FluidBufPitch.processBlocking(s,~src,features:~pitch_analysis);
)

// find the mean frequency... seems quite wrong, perhaps because there is some silence in the sound file with erroneous pitch values
(
~stats = Buffer(s);
FluidBufStats.processBlocking(s,~pitch_analysis,stats:~stats,numChans:1);
{
	var sig = LFTri.ar(BufRd.kr(1,~stats,0),0,-20.dbamp);
	var srcsig = PlayBuf.ar(1,~src,BufRateScale.ir(~src));
	var env = EnvGen.kr(Env([0,1,1,0],[0.03,~src.duration-0.06,0.03]),doneAction:2);
	sig = sig + srcsig;
	sig = sig * env;
	sig.dup;
}.play;
)

(
// using outliersCutoff, we can first remove any outliers, then take the mean pitch value...much more accurate!
~stats = Buffer(s);
FluidBufStats.processBlocking(s,~pitch_analysis,stats:~stats,outliersCutoff:1,numChans:1);
{
	var sig = LFTri.ar(BufRd.kr(1,~stats,0),0,-20.dbamp);
	var srcsig = PlayBuf.ar(1,~src,BufRateScale.ir(~src));
	var env = EnvGen.kr(Env([0,1,1,0],[0.03,~src.duration-0.06,0.03]),doneAction:2);
	sig = sig + srcsig;
	sig = sig * env;
	sig.dup;
}.play;
)

::
STRONG::A didactic example::
CODE::
// make a buffer of known length
b = Buffer.alloc(s,101);

// add known values - here, a ramp up
b.setn(0, Array.fill(101,{|i|i / 100}));

// create a new buffer as destinations
c = Buffer.new(s);

//run the process on them
(
Routine{
	t = Main.elapsedTime;
	FluidBufStats.process(s, b, stats:c, numDerivs:1).wait;
	(Main.elapsedTime - t).postln;
}.play
)

// list the statistics. The first seven are for the source buffer values themselves, the last seven for the first derivative of the source buffer.
c.getn(0,c.numFrames,{|item|item.postln;})

// replace the source values by a ramp down
b.setn(0, Array.fill(101,{|i| 1 - (i / 100)}));

// run the process and read the values
FluidBufStats.process(s, b, stats:c, numDerivs:1, action:{c.getn(0,c.numFrames,{|item|item.postln;})});

// replace the source values by halfsine
b.setn(0, Array.fill(101,{|i| (i * pi/ 100).sin}));
b.plot

// run the process and read the values
FluidBufStats.process(s, b, stats:c, numDerivs:1, action:{c.getn(0,c.numFrames,{|item|item.postln;})});

// replace the source values by partial halfsine
b.setn(0, Array.fill(101,{|i| (i * pi/ 50).sin.max(0)}));
b.plot

// run the process and read the values
FluidBufStats.process(s, b, stats:c, numDerivs:1, action:{c.getn(0,c.numFrames,{|item|item.postln;})});

// replace the source values by positive white noise
b.setn(0, Array.fill(101,{1.0.rand}));
b.plot

// run the process and read the values
FluidBufStats.process(s, b, stats:c, numDerivs:1, action:{c.getn(0,c.numFrames,{|item|item.postln;})});
::
