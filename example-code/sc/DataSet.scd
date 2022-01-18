
CODE::
// Create a simple a one-dimensional data set, three ways
// Using routine
s.reboot;
(
fork{
	~ds = FluidDataSet.new(s);
	~point = Buffer.alloc(s,1,1);
	s.sync;
	10.do{|i|
		~point.set(0,i);
		~ds.addPoint(i.asString,~point,{("addPoint"+i).postln});
		s.sync;
	};
	~ds.dump;
	s.sync;
	~ds.free;
};
)

//Using Dictionary
(
d = Dictionary.new;
d.add(\cols -> 1);
d.add(\data -> Dictionary.newFrom(10.collect{|i|[i.asString, [i.asFloat]]}.flatten));
fork{
	~ds = FluidDataSet.new(s);
	~ds.load(d); s.sync;
	~ds.dump; s.sync; ~ds.free;
}
)

// Using a synth
(
~ds = FluidDataSet.new(s);
{
	var trig = Impulse.kr(20);
	var count = PulseCount.kr(trig) - 1;
	var buf = LocalBuf(1);
	BufWr.kr(count, buf);
	FluidDataSetWr.kr(~ds.asUGenInput, idNumber: count, buf: buf, trig: trig);
	FreeSelf.kr(count - 8);
}.play.onFree{~ds.dump{|o| o.postln;~ds.free}}
)
::

STRONG:: Buffer Interface::

As the content of the dataset has a similar structure to buffers, namely arrays of floats in parallel, it is possible to transfer the content between the two. Careful consideration of the rotation of the buffer, as well as the relation of points to channel numbers, are needed.

code::
(
//Make a dummy data set
d = FluidDataSet(s);
~data = Dictionary.with(*Array.iota(20).reshape(4,5).collect{|a,i| ("row"++i)->a});
~dsdata = Dictionary.newFrom([\cols,5,\data,~data]);
d.load(~dsdata);
d.print;
)

//convert to separate buffer and labelset
b = Buffer(s);
l = FluidLabelSet(s);
d.toBuffer(b,0,l);

//check the result: by default, dataset points become frames, with their associated data columns as channels
b.query
b.getn(0,20,{|x|x.postln})
l.print

//you can also transpose your query, where dataset points are each a buffer channel, and each data column becomes a buffer frame
d.toBuffer(b,1,l);
b.query
b.getn(0,20,{|x|x.postln})
//note that the IDs are still one per item, as columns are unamed in datasets
l.print

//Convert back to DS again
e = FluidDataSet(s);

//Let's use the transposed data we just got
e.print;
e.fromBuffer(b,1,l);
e.print;
//if we didn't transpose, we would get an error as the labelset is mismatched with the number of items
e.clear
e.print
e.fromBuffer(b,0,l)
::

STRONG:: Merging Datasets::
code::
//this is how to add items between 2 datasets.
//create 2 datasets
(
~dsA = FluidDataSet.new(s);
~dsB = FluidDataSet.new(s);
)

//feed them items with same dimensions but different identifiers
~dsA.load(Dictionary.newFrom([\cols, 1, \data, Dictionary.newFrom([\one,1,\two,2])]));
~dsB.load(Dictionary.newFrom([\cols, 1, \data, Dictionary.newFrom([\three,3,\four,4])]));
~dsA.print;
~dsB.print;

// merge and check. it works.
~dsB.merge(~dsA)
~dsB.print;

//change the content of the dataset to shared identifiers
~dsA.load(Dictionary.newFrom([\cols, 1, \data, Dictionary.newFrom([\three,333,\four,444])]));
~dsB.load(Dictionary.newFrom([\cols, 1, \data, Dictionary.newFrom([\three,3,\four,4])]));
~dsA.print;
~dsB.print;

//try to merge, it does not update
~dsB.merge(~dsA)
~dsB.print;

// add the overwrite flag, and it works
~dsB.merge(~dsA,1)
~dsB.print;
::
