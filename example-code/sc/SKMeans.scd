code::

//Make some clumped 2D points and place into a DataSet
(
var points = 4.collect{
	64.collect{(1.sum3rand) + [1,-1].choose}.clump(2)
}.flatten(1) * 0.5;

var dict = Dictionary.with(
	*[
		\cols -> 2,
		\data -> Dictionary.newFrom(
			points.collect{|x, i| [i, x]}.flatten)
	]
);

~dataSet = FluidDataSet(s).load(dict).print;
)


// Create an SKMeans instance and a LabelSet for the cluster labels in the server
(
~clusters = FluidLabelSet(s);
~skmeans = FluidSKMeans(s);
)

// Fit into 4 clusters
(
~skmeans.fitPredict(~dataSet,~clusters,action: {|c|
	"Fitted.\n # Points in each cluster:".postln;
	c.do{|x,i|
		("Cluster" + i + "->" + x.asInteger + "points").postln;
	}
});
)

// Cols of SKMeans should match DataSet, size is the number of clusters

~skmeans.cols;
~skmeans.size;
~skmeans.dump;

(
var norm_ds = FluidDataSet(s);
FluidNormalize(s).fitTransform(~dataSet,norm_ds); // normalize for ease of viewing
norm_ds.dump{
	arg data;
	~clusters.dump{
		arg labels;
		defer{
			FluidPlotter(dict:data).categories_(labels);
		};
		norm_ds.free
	};
};
)

// single point query on arbitrary value
(
~inbuf = Buffer.loadCollection(s,{rrand(-1.0,1.0)} ! 2);
~skmeans.predictPoint(~inbuf,{|x|"cluster: ".post; x.postln;});
)

::
strong::Incremental Training::
code::

(
// peek at a the dataset
~dataSet.dump({
	arg dict;
	defer{
		~fp = FluidPlotter(dict:dict,xmin:-1,ymin:-1).pointSizeScale_(3);
	};
});
)

// now keeping that window open, do 10 fittings, watching how it changes after each
(
fork{
	~kmeans = FluidSKMeans(s,4,maxIter:1);
	~ls = FluidLabelSet(s);
	10.do{
		arg i;
		~kmeans.fitPredict(~dataSet,~ls,{
			~ls.dump({
				arg dict;
				~fp.categories_(dict);
			});
		});
		"Iteration: %".format(i+1).postln;
		1.wait;
	}
}
)

::

subsection:: Accessing the means

We can get and set the means for each cluster, their centroid.

code::

// with the dataset and skmeans generated and trained in the code above
(
~centroids = FluidDataSet(s);
~skmeans.getMeans(~centroids, {~centroids.print});
)

// We can also set them to arbitrary values to seed the process
(
~centroids.load(
	Dictionary.newFrom([
		\cols, 2,
		\data, Dictionary.newFrom([
			\0, [0.5,0.5],
			\1, [-0.5,0.5],
			\2, [0.5,-0.5],
			\3, [-0.5,-0.5]
		])
	])
);
~skmeans.setMeans(~centroids);
~skmeans.predict(~dataSet,~clusters);
~clusters.dump{
	arg dict;
	var count = 0.dup(4);
	dict["data"].keysValuesDo{
		arg k, v;
		count[v[0].asInteger] = count[v[0].asInteger] + 1;
	};
	"number of points in each cluster:".postln;
	count.postln
};
)

// We can further fit from the seeded means
~skmeans.fit(~dataSet)
// then retreive the improved means
~skmeans.getMeans(~centroids, {~centroids.print});
//subtle in this case but still.. each quadrant is where we seeded it.
::

subsection:: Cluster-distance Space

We can get the spherical distance of a given point to each cluster. SKMeans differ from KMeans as it takes the angular distance (cosine) of the vector. This is often referred to as the cluster-distance space as it creates new dimensions for each given point, one distance per cluster.

code::
// with the dataset and skmeans generated and trained in the code above
(
~inbuf = Buffer.sendCollection(s,[0.5,0.5]);
~encoded = Buffer(s)
)

// get the distance of our given point (b) to each cluster, thus giving us 4 dimensions in our cluster-distance space
(
~skmeans.encodePoint(~inbuf,~encoded,action:{
  ~encoded.getn(0,4,action:{
      arg dists;
      dists.postln;
  });
});
)

// we can also encode a full dataset
(
~cdspace = FluidDataSet(s);
// make a new dataset with 4 points
~srcDS = FluidDataSet(s).load(
	Dictionary.newFrom([
		\cols, 2,
		\data, Dictionary.newFrom([
			\pp, [0.5,0.5],
			\np, [-0.5,0.5],
			\pn, [0.5,-0.5],
			\nn, [-0.5,-0.5]
		])
	])
);
~skmeans.encode(~srcDS, ~cdspace);
~cdspace.print;
)
::

subsection:: Queries in a Synth

This is the equivalent of predictPoint, but wholly on the server

code::
(
{
	var trig = Impulse.kr(5);
	var point = WhiteNoise.kr(1.dup);
	var inputPoint = LocalBuf(2);
	var outputPoint = LocalBuf(1);
	Poll.kr(trig, point, [\pointX,\pointY]);
	point.collect{ |p,i| BufWr.kr([p],inputPoint,i)};
	~skmeans.kr(trig,inputPoint,outputPoint);
	Poll.kr(trig,BufRd.kr(1,outputPoint,0,interpolation:0),\cluster);
}.play;
)

// to sonify the output, here are random values alternating quadrant, generated more quickly as the cursor moves rightwards
(
{
	var trig = Impulse.kr(MouseX.kr(0,1).exprange(0.5,ControlRate.ir / 2));
	var step = Stepper.kr(trig,max:3);
	var point = TRand.kr(-0.1, [0.1, 0.1], trig) + [step.mod(2).linlin(0,1,-0.6,0.6),step.div(2).linlin(0,1,-0.6,0.6)] ;
	var inputPoint = LocalBuf(2);
	var outputPoint = LocalBuf(1);
	point.collect{|p,i| BufWr.kr([p],inputPoint,i)};
	~skmeans.kr(trig,inputPoint,outputPoint);
	SinOsc.ar((BufRd.kr(1,outputPoint,0,interpolation:0) + 69).midicps,mul: 0.1);
}.play;
)

::
