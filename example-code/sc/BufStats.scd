
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

STRONG::A musical example::

CODE::
// create some buffers
(
// a simple random sliding bell synth
b = {
	var trig = Impulse.ar(1.5);
	SinOsc.ar(
		Lag.ar(TRand.ar(trig: trig),
		TRand.ar(0.5, trig: trig)).exprange(333,666),
		mul: Decay.ar(
			trig * TRand.ar(0.1,10,trig),
			TRand.ar(0.5,1.1,trig)
		)
	).atan * 0.1;
}.asBuffer(20);
c = Buffer.new(s);
d = Buffer.new(s);
i = Buffer.new(s);
)

//play the source
b.play;

//split in various chunks, collecting the indices in an array
FluidBufOnsetSlice.process(s,b, threshold: 0.01, indices: c, action:{c.loadToFloatArray(action: {|array| e = array.add(b.numFrames);e.size.postln;e.postln;})});

//describe the whole input too, here using pitch, and collecting the values in an array, dismissing the (interleaved) confidence.
FluidBufPitch.process(s,b,features:d, windowSize: 4096, hopSize: 512, padding:2, action:{d.loadToFloatArray(action: {|array| f = array.unlace(2)[0]; f.postln;})});

// iterate through each slice, taking the median of the first derivative of the pitch of each
(
g= Array.new;
Routine({
	var nb = e.size;
	e.doAdjacentPairs({
		arg start,end;
		FluidBufStats.processBlocking(s,d,(start/512).asInteger,((end-start)/512).asInteger + 3,0,1,i,1, action: {
			i.loadToFloatArray( action: {
				arg array;
				g = g.add(array[12]);
				"% % %\n".postf((start/512).asInteger,((end-start)/512).asInteger + 3, array[12]);//adding some of the overlap but not more to not capture too much of the next attack
				nb = nb - 1;
				if (nb == 1, {"Done".postln;});//check if we've done all the pairs
			})
		}).wait;
	});
}).play;
)

//play in loop the slice in order of pitch direction (the median of the slice's pitch variation) - mouse on the left should be descending, in the middle should be more stable, and it should be ascending on the right.

(
Buffer.sendCollection(s,g.order,action: {|x| {
	var which = BufRd.kr(1, x, MouseX.kr(0, BufFrames.kr(x) - 1), 0, 1);
    BufRd.ar(1, b,
        Phasor.ar(0,1,
            BufRd.kr(1,c,which,0,1),
			BufRd.kr(1,c,which + 1,0,1),
			BufRd.kr(1,c,which,0,1)));
		}.play;
	};)
)

::


STRONG::Stereo Input Behaviour::

CODE::
// make a buffer of known lenght
b = Buffer.alloc(s,101,2);

// add known values - here, a ramp up on the left and negative random values on the right
b.setn(0, Array.fill(101,{|i|[i / 100,-1.0.rand]}).flat);

// plot to confirm
b.plot.plotMode_(\points)

// create a new buffer as destinations
c = Buffer.new(s);

// run the stats and send back the values
FluidBufStats.process(s, b, stats:c, numDerivs:1, action:{c.getn(0,c.numFrames * c.numChannels,{|item|d = item; d.postln})});

//looking at the result is not easy to grasp, since it is interleaved: first number is mean of L, second is mean of R, third is stddev of L, fourth is stddev or R
//this will make it tidier - the first value of each line is Left, the second is Right
d.reshape(14,2).do({|x,i|["mean\t\t","stddev\t\t","skew\t\t", "kurtosis\t\t", "min\t\t\t", "median\t\t", "max\t\t\t","d-mean\t","d-stddev\t","d-skew\t\t", "d-kurtosis", "d-min\t\t", "d-median\t", "d-max\t\t"].at(i).post;x.round(0.01).postln});"".postln;
::

STRONG::Outliers and Weights::

CODE::
// example 1a
// make a buffer of known qualities
b = Buffer.loadCollection(s,[1, 8, 9, 10, 11, 12, 99]);

// plot to confirm
b.plot.plotMode = \points;

// create a new buffer as destinations
c = Buffer.new(s);

// run the stats and send back the values
FluidBufStats.process(s, b, stats:c, numDerivs:1, action:{c.getn(0,c.numFrames,{|item|item.postln})});
// run the same array with outliers rejected if outside of 1.5 times the IQR - observe the new minimum and maximum to see
FluidBufStats.process(s, b, stats:c, numDerivs:1, outliersCutoff: 1.5, action:{c.getn(0,c.numFrames,{|item| item.postln})});

// example 1b (run the stats above, and change the value of some elements in the array too)
b = Buffer.loadCollection(s,[1, 8, 9, 10, 11, 12, 16, 99].scramble);

// example 1c (multichannel in behaviour is greedy)
// This mean that an outlier in any channel will dismiss the whole frame.
// For instance here the outlier is 99 (frame 8) in channel 0, and 1001 in channel 1 (frame 0)
// The final stats therefore has minima of [2,10002] and maxima of [8,10008]
e = [(1..8)++99, [1001] ++ 10002.series(10003,10009)].flop.scramble.flat
b = Buffer.loadCollection(s,e,2);
FluidBufStats.process(s, b, stats:c, numDerivs:1, outliersCutoff: 1.5, action:{c.getn(0,c.numFrames * c.numChannels,{|item| f =item.postln})});

//More readable format
f.reshape(14,2).do({|x,i|["mean\t\t","stddev\t\t","skew\t\t\t", "kurtosis\t", "min\t\t\t", "median\t\t", "max\t\t\t","d-mean\t","d-stddev\t","d-skew\t\t", "d-kurtosis", "d-min\t\t", "d-median\t", "d-max\t\t"].at(i).post;x.round(0.01).postln});"".postln;

//////////////
// example 2a

// make an array of 9 values, with known weigths. Scramble them pairwise for good measure (that should not change any stats)
e = [(1..9), 1.0.series(0.9,0.2)].flop.scramble.flop;
b = Buffer.loadCollection(s,e[0]);
c = Buffer.loadCollection(s,e[1]);
d = Buffer.new(s);
// run the stats and send back the values
FluidBufStats.process(s, b, stats:d, numDerivs:1, action:{d.getn(0,d.numFrames,{|item|item.postln})});
// run the same array with the weights
FluidBufStats.process(s, b, stats:d, numDerivs:1, weights: c, action:{d.getn(0,d.numFrames * d.numChannels,{|item|item.postln})});

// example 2b
e = [(1..9), 0.series(-10,-80)].flop.scramble.flop;
b = Buffer.loadCollection(s,e[0]);
c = Buffer.loadCollection(s,e[1]);
FluidBufStats.process(s, b, stats:d, numDerivs:1, weights: c, action:{d.getn(0,d.numFrames * d.numChannels,{|item|item.postln})});
// this has only negative weights, so it bails out, outputing all 0s. It also publishes a warning if the server options on verbosity are on.
// but if we scale them up
g = Buffer(s)
FluidBufScale.process(s,c,destination: g,inputLow: -100,inputHigh: 0)
// look at the new values - because 0->1 and -100->0 we get the same weights as example 2a
g.getn(0,9,{|x|x.postln})
// run the stats - same results as example 2a
FluidBufStats.process(s, b, stats:d, numDerivs:1, weights: g, action:{d.getn(0,d.numFrames * d.numChannels,{|item|item.postln})});

//example 2c (stereo input but mono weigths - works like a charm)
e = [(1..9), (101..109), 1.0.series(0.9,0.2)].flop.scramble.flop;
b = Buffer.loadCollection(s,e[0..1].flop.flat,2);
b.plot(separately: true).plotMode = \points;
c = Buffer.loadCollection(s,e[2]);
FluidBufStats.process(s, b, stats:d, numDerivs:1, weights: c, action:{d.getn(0,d.numFrames * d.numChannels,{|item|f = item.postln})});

//More readable format
f.reshape(14,2).do({|x,i|["mean\t\t","stddev\t\t","skew\t\t\t", "kurtosis\t", "min\t\t\t", "median\t\t", "max\t\t\t","d-mean\t","d-stddev\t","d-skew\t\t", "d-kurtosis", "d-min\t\t", "d-median\t", "d-max\t\t"].at(i).post;x.round(0.01).postln});"".postln;

//see the example folder for 2 musical comparisons: 1) weighted MFCCs providing different nearest neighbours, and 2) pitch manipulations
::
