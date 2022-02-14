
code::
// Make a DataSet of random 2D points
s.reboot;
(
fork{
	d = Dictionary.with(
		*[\cols -> 2,\data -> Dictionary.newFrom(
			100.collect{|i| [i, [ 1.0.linrand,1.0.linrand]]}.flatten)]);
	~ds = FluidDataSet(s);
	~ds.load(d, {~ds.print});
}
)

// Make a new tree, and fit it to the DataSet
~tree = FluidKDTree(s,numNeighbours:5);

//Fit it to the DataSet
~tree.fit(~ds);

// Should be 100 points, 2 columns
~tree.size;
~tree.cols;

//Return the labels of k nearest points to a new point
(
~p = [ 1.0.linrand,1.0.linrand ];
~tmpbuf = Buffer.loadCollection(s, ~p, 1, {
	~tree.kNearest(~tmpbuf,{ |a|a.postln;~nearest = a;})
});
)

// Retrieve values from the DataSet by iterating through the returned labels
(
fork{
	~nearest.do{|n|
		~ds.getPoint(n, ~tmpbuf, {~tmpbuf.getn(0, 2, {|x|x.postln})});
		s.sync;
	}
}
)
// Distances of the nearest points
~tree.kNearestDist(~tmpbuf, { |a| a.postln });

// Explore changing the number of neighbourgs
~tree.numNeighbours = 11; // note that this value needs to be sent to the server
~tree.kNearest(~tmpbuf,{ |a|a.postln;});
~tree.numNeighbours = 0; // 0 will return all items in order of distance
~tree.kNearest(~tmpbuf,{ |a|a.postln;});

// Limit the search to an acceptable distance in a radius
// Define a point, and observe typical distance values
~p = [ 0.4,0.4];
(
~tmpbuf = Buffer.loadCollection(s, ~p, 1, {
	~tree.kNearest(~tmpbuf,{ |a|a.postln;});
	~tree.kNearestDist(~tmpbuf,{ |a|a.postln;});
});
)

// enter a valid radius.
~tree.radius = 0.1;
// FluidKDTree will return only values that are within that radius, up to numNeighbours values
(
~tmpbuf = Buffer.loadCollection(s, ~p, 1, {
	~tree.kNearest(~tmpbuf,{ |a|a.postln;});
});
)
::

subsection:: Queries in a Synth

Input and output is done via buffers, which will need to be preallocated to the correct sizes:
LIST::
##Your input buffer should be sized to the input data dimension (2, in this example)
##Your output buffer should be the number of neighbours * output dimensionality
::

We can't simply return labels (i.e. strings) from a UGen, so the query returns the actual data points from a DataSet instead. By default, this is the FluidDataSet against which the tree was fitted. However, by passing a different dataset to code::kr::'s code::lookupDataSet:: argument instead, you can return different points, so long as the labels in the two datasets match. In this way, the FluidKDTree can be used to perform nearest neighbour mappings in a synth.

For instance, whilst fitting the tree against some n-dimensional descriptor data, our lookup dataset could use the same labels to map descriptor entries back to buffers, or locations in buffers, so that queries can be used to trigger audio.

code::

(
Routine{
    var inputBuffer = Buffer.alloc(s,2);
    var outputBuffer = Buffer.alloc(s,10);//5 neighbours * 2D data points
    s.sync;
    {
        var trig = Impulse.kr(4); //can go as fast as ControlRate.ir/2
        var point = 2.collect{TRand.kr(0,1,trig)};
        point.collect{|p,i| BufWr.kr([p],inputBuffer,i)};
        ~tree.kr(trig,inputBuffer,outputBuffer,5,nil);
		Poll.kr(trig, BufRd.kr(1,outputBuffer,Array.iota(10)),10.collect{|i| "Neighbour" + (i/2).asInteger ++ "-" ++ (i.mod(2))});
        Silent.ar;
    }.play;
}.play;
)

//Using a lookup data set instead:
//here we populate with numbers that are in effect the indicies, but it could be anything numerical that will be returned on the server-side and would be usable on that side
(
fork{
	d = Dictionary.with(
		*[\cols -> 1,\data -> Dictionary.newFrom(
			100.collect{|i| [i, [ i ]]}.flatten)]);
	~dsL = FluidDataSet.new(s);
	~dsL.load(d, {~dsL.print});
}
)

// Create the buffers, and make a synth, querying our tree with some random points
(
Routine{
    var inputBuffer = Buffer.alloc(s,2);
    var outputBuffer = Buffer.alloc(s,5);//5 neighbours * 1D points
    s.sync;
    {
        var trig = Impulse.kr(4); //can go as fast as ControlRate.ir/2
        var point = 2.collect{TRand.kr(0,1,trig)};
        point.collect{|p,i| BufWr.kr([p],inputBuffer,i)};
        ~tree.kr(trig,inputBuffer,outputBuffer,5,~dsL);
		Poll.kr(trig, BufRd.kr(1,outputBuffer,Array.iota(5)),5.collect{|i| "Neighbour" + i});
        Silent.ar;
    }.play;
}.play;
)
::
