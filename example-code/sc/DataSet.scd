CODE::

(
~ds = FluidDataSet(s);
~databuf = Buffer.loadCollection(s,[0]);
)

// add a point
(
~ds.addPoint("my-point",~databuf);
~ds.print;
)

// setPoint adds a point or, if the identifier exists, updates the point
(
fork{
	~databuf.set(0,99);
	~ds.setPoint("my-point",~databuf);
	s.sync;
	~databuf.set(0,87);
	~ds.setPoint("another-point",~databuf);
	~ds.print;
}
)

// update an existing point
(
~databuf.set(0,236);
~ds.updatePoint("another-point",~databuf);
~ds.print;
)

// get a point
(
~ds.getPoint("my-point",~databuf);
~databuf.loadToFloatArray(action:{
	arg fa;
	fa.postln;
});
)

// delete a point
(
~ds.deletePoint("my-point");
~ds.print;
)

::
strong::Adding an audio analysis to a DataSet::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));

// add just the mean mfcc values to the dataset
(
~mfccs = Buffer(s);
~stats = Buffer(s);
~flat = Buffer(s);
FluidBufMFCC.processBlocking(s,~src,features:~mfccs);
FluidBufStats.processBlocking(s,~mfccs,stats:~stats,select:[\mean]);
FluidBufFlatten.processBlocking(s,~stats,destination:~flat);
FluidDataSet(s).addPoint("ASWINE",~flat).print;
)

// use .fromBuffer to add *every* mfcc analysis to the dataset
(
FluidBufMFCC.processBlocking(s,~src,features:~mfccs);
FluidDataSet(s).fromBuffer(~mfccs).print;
)

::
strong::Four ways to get a bunch of data into a dataset::
code::
// Using routine
(
fork{
	var point = Buffer.alloc(s,1);
	var ds = FluidDataSet(s);
	s.sync;
	10.do{
		arg i;
		point.set(0,i);
		ds.addPoint("point-%".format(i),point);
		s.sync;
	};
	ds.print;
};
)

//Using Dictionary
(
var dict = Dictionary.new;
dict.put(\cols,1);
dict.put(\data,
	Dictionary.newFrom(
		[ // one could, of course, make this array more programmatically
			"point-0",0,
			"point-1",1,
			"point-2",2,
			"point-3",3,
			"point-4",4,
			"point-5",5,
			"point-6",6,
			"point-7",7,
			"point-8",8,
			"point-9",9
		]
	)
);
FluidDataSet(s).load(dict).print;
)

// Using a synth
(
var ds = FluidDataSet.new(s);
{
	var trig = Impulse.kr(20);
	var count = PulseCount.kr(trig) - 1;
	var buf = LocalBuf(1);
	BufWr.kr(count, buf);
	FluidDataSetWr.kr(ds, idNumber: count, buf: buf, trig: trig);
	FreeSelf.kr(count - 8);
}.play.onFree{ds.print}
)

// from a buffer
(
fork{
	var buf = Buffer.loadCollection(s,(0..9));
	s.sync;
	FluidDataSet(s).fromBuffer(buf).print;
}
)
::
strong::More Messages::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));

// use .fromBuffer to add *every* mfcc analysis to the dataset
(
~mfccs = Buffer(s);
FluidBufMFCC.processBlocking(s,~src,features:~mfccs);
~ds = FluidDataSet(s).fromBuffer(~mfccs).print;
)

// write to disk
~ds.write(Platform.defaultTempDir+/+"temp_dataset.json");

// read from disk
(
~loaded_ds = FluidDataSet(s).read(Platform.defaultTempDir+/+"temp_dataset.json");
~loaded_ds.print;
)

// how many data points are there
~ds.size

// how many dimensions
~ds.cols

// dump the contents to a language side dict
(
~ds.dump({
	arg dict;
	dict["data"].keysValuesDo{
		arg k, v;
		"%:\t%".format(k,v).postln;
	};
	"this data set has % dimensions".format(dict["cols"]).postln;
});
)

// clear it
(
~ds.clear;
~ds.print;
)
::

strong::Merge two data sets that have the same number of dimensions::
code::

// Make two simple dataset
a = Dictionary.newFrom([\cols, 2, \data, Dictionary.newFrom([\one, [1, 1.1] ,\two, [2, 2.2]])]);
b = FluidDataSet(s)
b.load(a)
b.print

a = Dictionary.newFrom([\cols, 2, \data, Dictionary.newFrom([\three, [3, 3.3] , \two, [0.2, -2]])]);
c = FluidDataSet(s)
c.load(a)
c.print

b.merge(c)
b.print //common items not replaced

b.merge(c,1)
b.print //now they are

::

strong::Using:: code::.fromBuffer::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));

// use .fromBuffer to add *every* mfcc analysis to the dataset
// pass a labelset so the identifiers aren't just numbers
(
fork{
	~mfccs = Buffer(s);
	FluidBufMFCC.processBlocking(s,~src,features:~mfccs);
	s.sync;
	~ls = FluidLabelSet(s);
	~mfccs.numFrames.do{
		arg i;
		// in the label set that gets used to create
		// the identifiers, the identifier is the
		// frame number in the buffer (an integer)
		// and the "label" is what will be come the
		// identifier in the dataset
		~ls.addLabel(i,"ASWINE-mfcc-%".format(i));
	};
	~ds = FluidDataSet(s).fromBuffer(~mfccs,0,~ls).print;
}
)

// You can provide an optional number (0 or 1) to change the transposition of the copying.
~ds.fromBuffer(~mfccs,1).print;

// By default, each row is layed out framewise, so all of channel 1 is ordered in time as the columns of identifier 0.
// When frombuffer <buffer> 1 is passed, the copying is transposed. This means each identifier will contain the same index across all channels as the columns of a given identifier.
::

strong::Using:: code::.toBuffer::
code::

// use .toBuffer to convert the dataset into a buffer.

// make a simple 2D dataset
(
~buffer = Buffer(s);
~ds = FluidDataSet(s).load(Dictionary.newFrom([\cols, 2, \data, Dictionary.newFrom([\bottom_left,\top_left,\bottom_right,\top_right].collect{|n,i|[n, [i.div(2), i.mod(2)]]}.flatten)])).print;
~ls = FluidLabelSet(s);
)

// toBuffer messages copies the contents of the dataset to the buffer provided as an argument.
~ds.toBuffer(~buffer, action: {~buffer.loadToFloatArray(action: {|x|x.postln})})

//By default, each point/item is layed out framewise, so the 0th frame is the first item, where each dimension is a channel. When tobuffer <multiarray> 1 is passed, the copying is transposed. This means each channel will hold a point, and each frame will represent a dimension.

// You can provide an optional number (0 or 1) to change the transposition of the copying, and an optional labelset to get.
~ds.toBuffer(~buffer, transpose: 1, labelSet: ~ls, action: {~buffer.loadToFloatArray(action: {|x|x.postln; ~ls.print})})

// Finally, you can swap the order of the entries in the labelset. This is convenient to retrieve from an original identifier on what frame/channel a point/item will be found
~ds.toBuffer(~buffer, transpose: 1, labelSet: ~ls, labelwise: 1, action: {~buffer.loadToFloatArray(action: {|x|x.postln; ~ls.print})})
::

strong::Nearest Neighbour Search in a DataSet::

Note: A FluidDataSet can be queried with an input point to return the nearest match to that point. Note: This feature is can be computationally expensive on a large dataset, as it needs to compute the distance of the queried point to each point in the dataset. If you need to perform multiple nearest neighbour queries on a fluid.dataset~ it is recommended to use FluidKDTree. This facility is most useful with smaller, ephemeral datasets such as those returned by FluidDataSetQuery.

code::

// create a small DataSet...
f = FluidDataSet(s)
// and fill it with a grid of data
f.load(Dictionary.newFrom(["cols", 2, "data", Dictionary.newFrom(9.collect{|i|["item-%".format(i), [i.div(3), i.mod(3)] / 2]}.flatten(1))]))

// the data looks like this
// (item-0 -> [ 0.0, 0.0 ]) (item-1 -> [ 0.0, 0.5 ]) (item-2 -> [ 0.0, 1.0 ])
// (item-3 -> [ 0.5, 0.0 ]) (item-4 -> [ 0.5, 0.5 ]) (item-5 -> [ 0.5, 1.0 ])
// (item-6 -> [ 1.0, 0.0 ]) (item-7 -> [ 1.0, 0.5 ]) (item-8 -> [ 1.0, 1.0 ])

// create a query buffer...
b = Buffer.alloc(s,2)

// and fill it with a point
b.sendCollection([1,0]);

// and request 9 nearest neighbours
f.kNearest(b,9,{|x|x.postln;})

// and request the distances
f.kNearestDist(b,9,{|x|x.postln;})

// even more daring/crazy/dangerous: bruteforce search on the server

// make a lookup table where each label is itselt as a number
g = FluidDataSet(s).load(Dictionary.newFrom(["cols", 1, "data", Dictionary.newFrom(9.collect{|i|["item-%".format(i), i]}.flatten(1))]))
// and a lookup buffer
c = Buffer.alloc(s,6)

// if provided with a lookup dataset, outputs these values
(
{
	var trig = Impulse.kr(1);
	FluidKrToBuf.kr(SinOsc.kr(0.25,[0,pi/2]).poll(trig,\in), b); //going in the 4 quadrants
	f.kr(trig, inputBuffer: b, outputBuffer: c, numNeighbours: 6, lookupDataSet: g).poll(trig,\numvalid);
	FluidBufToKr.kr(c).poll(trig,\out);
}.play;
)

// if not provided with a lookup dataset, it outputs the distances to the nearest neighbour. Also, notice how the numNeighbours is tapered down to match the destination buffer (c) size.
(
{
	var trig = Impulse.kr(1);
	FluidKrToBuf.kr(SinOsc.kr(0.25,[0,pi/2]).poll(trig,\in), b); //going in the 4 quadrants
	f.kr(trig, inputBuffer: b, outputBuffer: c, numNeighbours: 8).poll(trig,\numvalid);
	FluidBufToKr.kr(c).poll(trig,\out);
}.play;
)

