code::

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
~features = Buffer(s);
FluidBufMFCC.processBlocking(s,~src,features:~features,startCoeff:1);
~ds = FluidDataSet(s).fromBuffer(~features);
~ds2d = FluidDataSet(s);
~ds2dN = FluidDataSet(s);
FluidMDS(s).fitTransform(~ds,~ds2d);
FluidNormalize(s).fitTransform(~ds2d,~ds2dN);
~ds2dN.dump({
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
	var win = Window("Comparing Distance Measures",Rect(0,0,1200,800));
	["Manhattan","Euclidean","Squared Euclidean","Minkowski Max","Minkowski Min","Symmetric Kullback Leibler"].do{
		arg name, dist_measure;
		var ds_transformed = FluidDataSet(s);
		var ds_trans_normed = FluidDataSet(s);
		"computing distance measure: % %".format(dist_measure, name).postln;
		FluidMDS(s,2,dist_measure).fitTransform(~ds,ds_transformed);
		FluidNormalize(s).fitTransform(ds_transformed,ds_trans_normed);
		ds_trans_normed.dump({
			arg dict;
			defer{
				var x = (dist_measure * 400) % win.bounds.width;
				var y = (dist_measure / 3).floor * 400;
				FluidPlotter(win,Rect(x + 5,y + 5,390,390),dict);
				UserView(win,Rect(x + 5,y + 5,390,390))
				.drawFunc_{
					Pen.stringAtPoint(name + "Distance",Point(10,10),color:Color.red);
				};
			};
		});
		s.sync;
	};
	win.front;
},AppClock);
)

::
