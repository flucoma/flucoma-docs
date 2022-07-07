code::

(
// peek at a didactic dataset (color is just to track better where the points end up)
~ds = FluidDataSet(s).read(FluidFilesPath("../Data/moon.json"));
~colors = Dictionary.new;
~ds.dump({
	arg dict;
	dict["data"].keysValuesDo{
		arg k, v;
		var hsl = Color.hsv(v[0],1,0.5);
		~colors[k] = Color(v[0],v[1],hsl.red);
	};

	defer{
		var fp = FluidPlotter(dict:dict);
		~colors.keysValuesDo{
			arg k, v;
			fp.pointColor_(k,v);
		};
		fp.pointSizeScale_(3);
	};
});
)

// now gridify it
(
~ds_gridded = FluidDataSet(s);
~grid = FluidGrid(s).fitTransform(~ds,~ds_gridded);

// by default it is not normalized, so we'll do that before
// sending it to plotter
FluidNormalize(s).fitTransform(~ds_gridded,~ds_gridded);

~ds.dump({
	arg original;
	~ds_gridded.dump({
		arg gridded;
		defer{
			var win = Window(bounds:Rect(0,0,1000,500));
			var fps = [original,gridded].collect{
				arg dict;
				var fp = FluidPlotter(dict:dict,standalone:false);
				~colors.keysValuesDo{
					arg k, v;
					fp.pointColor_(k,v);
				};
				fp.pointSizeScale_(3);
				fp;
			};
			win.layout_(HLayout(*fps));
			win.front;
		};
	});
});
)
::
strong::Oversampling::
code::

// if we added an oversampling of 4 to the example above,
// there will be 4x as many points on the grid as there are
// in the dataset. they don't all get used, so we can still
// see some of the original shape
(
~ds_gridded = FluidDataSet(s);
~grid = FluidGrid(s,4).fitTransform(~ds,~ds_gridded);

// by default it is not normalized, so we'll do that before
// sending it to plotter
FluidNormalize(s).fitTransform(~ds_gridded,~ds_gridded);

~ds.dump({
	arg original;
	~ds_gridded.dump({
		arg gridded;
		defer{
			var win = Window(bounds:Rect(0,0,1000,500));
			var fps = [original,gridded].collect{
				arg dict;
				var fp = FluidPlotter(dict:dict,standalone:false);
				~colors.keysValuesDo{
					arg k, v;
					fp.pointColor_(k,v);
				};
				fp.pointSizeScale_(3);
				fp;
			};
			win.layout_(HLayout(*fps));
			win.front;
		};
	});
});
)

::
strong::Axis and Extent::
code::

// by adding an extent of 5 to axis 0, we get 5 columns:
(
~ds_gridded = FluidDataSet(s);
~grid = FluidGrid(s,oversample:1,extent:5,axis:0).fitTransform(~ds,~ds_gridded);

// by default it is not normalized, so we'll do that before
// sending it to plotter
FluidNormalize(s).fitTransform(~ds_gridded,~ds_gridded);

~ds.dump({
	arg original;
	~ds_gridded.dump({
		arg gridded;
		defer{
			var win = Window(bounds:Rect(0,0,1000,500));
			var fps = [original,gridded].collect{
				arg dict;
				var fp = FluidPlotter(dict:dict,standalone:false);
				~colors.keysValuesDo{
					arg k, v;
					fp.pointColor_(k,v);
				};
				fp.pointSizeScale_(3);
				fp;
			};
			win.layout_(HLayout(*fps));
			win.front;
		};
	});
});
)


// different settings
(
~ds_gridded = FluidDataSet(s);
~grid = FluidGrid(s,oversample:1,extent:7,axis:1).fitTransform(~ds,~ds_gridded);

// by default it is not normalized, so we'll do that before
// sending it to plotter
FluidNormalize(s).fitTransform(~ds_gridded,~ds_gridded);

~ds.dump({
	arg original;
	~ds_gridded.dump({
		arg gridded;
		defer{
			var win = Window(bounds:Rect(0,0,1000,500));
			var fps = [original,gridded].collect{
				arg dict;
				var fp = FluidPlotter(dict:dict,standalone:false);
				~colors.keysValuesDo{
					arg k, v;
					fp.pointColor_(k,v);
				};
				fp.pointSizeScale_(3);
				fp;
			};
			win.layout_(HLayout(*fps));
			win.front;
		};
	});
});
)

// this can also be over sampled:
(
~ds_gridded = FluidDataSet(s);
~grid = FluidGrid(s,oversample:12,extent:6,axis:0).fitTransform(~ds,~ds_gridded);

// by default it is not normalized, so we'll do that before
// sending it to plotter
FluidNormalize(s).fitTransform(~ds_gridded,~ds_gridded);

~ds.dump({
	arg original;
	~ds_gridded.dump({
		arg gridded;
		defer{
			var win = Window(bounds:Rect(0,0,1000,500));
			var fps = [original,gridded].collect{
				arg dict;
				var fp = FluidPlotter(dict:dict,standalone:false);
				~colors.keysValuesDo{
					arg k, v;
					fp.pointColor_(k,v);
				};
				fp.pointSizeScale_(3);
				fp;
			};
			win.layout_(HLayout(*fps));
			win.front;
		};
	});
});
)
::
strong::With Sound::

Using link::Classes/FluidUMAP:: to dimensionally reduce 13 dimensions of link::Classes/FluidBufMFCC:: analyses down to two dimensions, play with each of the plots and see which is more musically expressive. Each has it's strenghts and weaknesses!
code::

~src = Buffer.readChannel(s,FluidFilesPath("Green-Box641.wav"),channels:[0]);

// make a dataset of MFCC analyses all 100 ms long, the id is the sample it starts at
(
var mfccs = Buffer(s);
var stats = Buffer(s);
var flat = Buffer(s);
var currentSample = 0;
var hopSamples = ~src.sampleRate * 0.1;
~ds = FluidDataSet(s);
while({
	(currentSample + hopSamples) < ~src.numFrames;
},{
	FluidBufMFCC.processBlocking(s,~src,currentSample,hopSamples,startCoeff:1,features:mfccs);
	FluidBufStats.processBlocking(s,mfccs,stats:stats,select:[\mid]);
	FluidBufFlatten.processBlocking(s,stats,destination:flat);
	~ds.addPoint(currentSample.asInteger,flat);
	currentSample = currentSample + hopSamples;
});
~ds.print;
)

// do the data stuff
(
~ds_umap = FluidDataSet(s);
FluidUMAP(s,2,15,0.5).fitTransform(~ds,~ds_umap); // reduce 13 dimensions to 2 dimensions
FluidNormalize(s).fitTransform(~ds_umap,~ds_umap); // normalize it so it plots nicely
~ds_grid = FluidDataSet(s);
FluidGrid(s).fitTransform(~ds_umap,~ds_grid); // gridify it into another dataset
FluidNormalize(s).fitTransform(~ds_grid,~ds_grid); // normalize that too so it plots nicely
~win = Window(bounds:Rect(0,0,1000,500));
[~ds_umap,~ds_grid].do{
	arg ds, i;
	ds.dump({
		arg dict;
		var buf = Buffer.alloc(s,2);
		var tree = FluidKDTree(s).fit(ds);
		var last = nil;
		defer{
			FluidPlotter(~win,Rect((i*500) + 10,10,480,480),dict,{
				arg view, x, y;
				buf.setn(0,[x,y]);
				tree.kNearest(buf,1,{
					arg id;
					if(id != last){
						last = id;
						view.highlight_(id);
						{
							var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),1,id.asInteger);
							var env = EnvGen.kr(Env([0,1,1,0],[0.02,0.06,0.02]),doneAction:2);
							sig.dup * env;
						}.play;
					};
				});
			},standalone:false);
		}
	});
};
~win.front;
)


::