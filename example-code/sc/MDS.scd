code::

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
~features = Buffer(s);
FluidBufMFCC.processBlocking(s,~src,features:~features,startCoeff:1);
~ds = FluidDataSet(s).fromBuffer(~features);
FluidMDS(s).fitTransform(~ds,~ds);
FluidNormalize(s).fitTransform(~ds,~ds);
~ds.dump({
	arg dict;
	{FluidPlotter(bounds:Rect(0,0,800,800),dict:dict)}.defer;
});
)

::
strong::Comparing Distance Measures::

Just looking at these plots won't really reveal the differences between these distance measures--the best way to see which might be best is to test them on your own data and listen to the musical differences they create!
code::

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
~features = Buffer(s);
FluidBufMFCC.processBlocking(s,~src,features:~features,startCoeff:1);
~ds = FluidDataSet(s).fromBuffer(~features);

fork({
	var win = Window("Comparing Distance Measures",Rect(0,0,1600,800));
	["Manhattan","Euclidean","Squared Euclidean","Minkowski Max","Minkowski Min","Symmetric Kullback Leibler","Cosine"].do{
		arg name, dist_measure; //they're the same here
		var ds_transformed = FluidDataSet(s);
		"computing distance measure: %".format(dist_measure).postln;
		FluidMDS(s,2,dist_measure).fitTransform(~ds,ds_transformed);
		FluidNormalize(s).fitTransform(ds_transformed,ds_transformed);
		ds_transformed.dump({
			arg dict;
			defer{
				var x = (dist_measure * 400) % win.bounds.width;
				var y = (dist_measure / 4).floor * 400;
				FluidPlotter(win,Rect(x + 5,y + 5,390,390),dict);
			};
		});
		s.sync;
	};
	win.front;
},AppClock);
)

::