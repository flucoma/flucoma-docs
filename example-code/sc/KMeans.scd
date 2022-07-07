code::

(
// peek at a didactic dataset
~ds = FluidDataSet(s).read(FluidFilesPath("../Data/moon.json"));
~ds.dump({
	arg dict;
	defer{
		~fp = FluidPlotter(dict:dict).pointSizeScale_(3);
	};
});
)

// now keeping that window open, try some different numbers for k
(
~kmeans = FluidKMeans(s);
~ls = FluidLabelSet(s);
)

// k = the default of 4
(
~kmeans.fitPredict(~ds,~ls,{
	~ls.dump({
		arg dict;
		~fp.categories_(dict);
	});
});
)

// k = 2
(
~kmeans.numClusters_(2).fitPredict(~ds,~ls,{
	~ls.dump({
		arg dict;
		~fp.categories_(dict);
	});
});
)

// k = 9
(
~kmeans.numClusters_(9).fitPredict(~ds,~ls,{
	~ls.dump({
		arg dict;
		~fp.categories_(dict);
	});
});
)

::
strong::Incremental Training::
code::

// Keep the window open and run this to see where it's at after each iteration

(
fork{
	~kmeans.clear;
	~kmeans.numClusters_(9);
	~kmeans.maxIter_(1);
	10.do{
		arg i;
		~kmeans.fitPredict(~ds,~ls,{
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
strong::Seeding the Means::
code::

(
// peek at a didactic dataset
~ds = FluidDataSet(s).read(FluidFilesPath("../Data/gaussian4.json"));
~ds.dump({
	arg dict;
	defer{
		~fp = FluidPlotter(dict:dict);
	};
});
)

// keep that window open and let's display where we will
// seeds the means
(
~seeds = [[0.1,0.1],[0.2,0.2],[0.3,0.3],[0.4,0.4]];
~seeds.do{
	arg arr, i;
	~fp.addPoint_("seed-%".format(i),arr[0],arr[1],Color.gray,3);
}
)

// do 10 iterations and see where the seeds move to from their starting locations
(
fork{
	// put the seed means that we're going to use in a data set
	// so that we can set them with FluidKMeans' method "setMeans"
	~ds_means = FluidDataSet(s).load(
		Dictionary.newFrom([
			"cols",2,
			"data",Dictionary.newFrom([
				"seed-0",~seeds[0],
				"seed-1",~seeds[1],
				"seed-2",~seeds[2],
				"seed-3",~seeds[3],
			])
		])
	);
	~kmeans = FluidKMeans(s);
	~kmeans.setMeans(~ds_means); // set the staring means
	// set max iter to 1 so we can seen the progress unfold one step at a time
	~kmeans.maxIter_(1);
	// labelset for FluidKMeans to write the categories into
	~ls = FluidLabelSet(s);

	// just do 10 iterations (probably will be enough)
	10.do{
		arg i;
		// do one iteration of fit and write the current category lables
		~kmeans.fitPredict(~ds,~ls,{
			~ls.dump({
				arg dict;

				// set those categories to fluid plotter so we can see the colors
				~fp.categories_(dict);
			});

			// also get the means' current positions and...
			~kmeans.getMeans(~ds_means,{
				~ds_means.dump({
					arg dict;

					// update their position on the screen
					dict["data"].keysValuesDo{
						arg k, v;
						~fp.setPoint_("seed-%".format(k),v[0],v[1],Color.gray,3);
					};
				});
			});
		});
		"Iteration: %".format(i+1).postln;
		1.wait;
	}
}
)
::
strong::Distances::

Accessing the distances to each point's mean
code::

(
// peek at a didactic dataset
~ds = FluidDataSet(s).read(FluidFilesPath("../Data/gaussian4.json"));
~ds.dump({
	arg dict;
	defer{
		~fp = FluidPlotter(dict:dict).pointSizeScale_(2);
	};
});
)

// keep that window open and run KMeans analysis, then color the points according to their distance from their mean
(
var ds_dist = FluidDataSet(s);
var ds_means = FluidDataSet(s);
var kmeans = FluidKMeans(s).maxIter_(300).fitTransform(~ds,ds_dist);
kmeans.getMeans(ds_means);
~ds.dump({
	arg dict;
	ds_dist.dump({
		arg dist_dict;
		ds_means.dump({
			arg means_dict;

			dist_dict["data"].keysValuesDo{
				arg id, dist;

				// it provides a distance to every mean, so we'll use the
				// smallest value
				dist = dist.minItem;
				id.postln;
				dist.postln;
				~fp.pointColor_(id,Color.hsv(dist * 10,1,1));
			};

			means_dict["data"].keysValuesDo{
				arg k, v;
				~fp.addPoint_("mean-%".format(k),v[0],v[1],Color.gray,3);
			};
		});
	});
});
)

::