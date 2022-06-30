code::

// Using UMAP we'll reduce this dataset from 26 dimensions (26 MFCC values) down to 2 dimensions so we can plot it
(
~loader = FluidLoadFolder(FluidFilesPath()).play; // load the audio (all the files in the FluCoMa audio files folder!)
~slicePoints = Buffer.read(s,FluidFilesPath("../Data/flucoma_corpus_slices.wav")); // load the slice positions of the audio
~ds_mfcc = FluidDataSet(s).read(FluidFilesPath("../Data/flucoma_corpus_mfcc.json")); // load the pre-analyzed dataset
)

// reduce and plot
// try changing the numNeighbours and minDist to see how it affects the plot.
(
var reduced = FluidDataSet(s);
var tree;
FluidUMAP(s,2,numNeighbours:15,minDist:0.1).fitTransform(~ds_mfcc,reduced);
FluidNormalize(s).fitTransform(reduced,reduced);// normalize so it's easier to plot
tree = FluidKDTree(s).fit(reduced); // use a kdtree to find the point nearest to the mouse position
reduced.dump({
	arg dict;
	var xybuf = Buffer.alloc(s,2);
	defer{
		FluidPlotter(dict:dict,mouseMoveAction:{
			arg view, x, y;
			xybuf.setn(0,[x,y]);
			tree.kNearest(xybuf,1,{
				arg id;
				var index = id.asInteger;
				defer{
					view.highlight_(id);
				};

				{
					var start = Index.kr(~slicePoints,index);
					var end = Index.kr(~slicePoints,index+1);
					var sig = PlayBuf.ar(2,~loader.buffer,BufRateScale.ir(~loader.buffer),1,start)[0];
					var dur_sec = min((end-start) / SampleRate.ir,1);
					var env = EnvGen.kr(Env([0,1,1,0],[0.03,dur_sec-0.06,0.03]),doneAction:2);
					sig.dup * env;
				}.play;
			});
		});
	};
});
)

::
strong::Reducing a 3 dimensional colour space to 2 dimensional space::
code::

// make a dataset of 100 random 3 dimensional points (that will later be RGB values)
(
~ds_rgb = FluidDataSet(s).load(
	Dictionary.newFrom([
		"cols",3,
		"data",Dictionary.newFrom(
			100.collect{
				arg i;
				[i,{rrand(0.0,1.0)} ! 3]
			}.flatten;
		)
	])
);
~ds_rgb.print;
)

// rather than trying to plot these points in 3 dimensional space,
// we'll reduce it to 2 dimensional space so it looks better on a screen
// again play around with the arguments numNeighbours and minDist to see
// how they affect he spread of the points
(
var reduced = FluidDataSet(s);
FluidUMAP(s,2,numNeighbours:15,minDist:0.6).fitTransform(~ds_rgb,reduced);
FluidNormalize(s).fitTransform(reduced,reduced);
~ds_rgb.dump{
	arg rgb;
	reduced.dump{
		arg xy;
		defer{
			var fp = FluidPlotter(dict:xy).pointSizeScale_(2);
			rgb["data"].keysValuesDo{
				arg k, v;
				fp.pointColor_(k,Color(*v));
			};
		};
	};
};
)

::
strong::Retrieving values on the server::
code::

// Using UMAP we'll reduce this dataset from 26 dimensions (26 MFCC values) down to 2 dimensions
// wait for it to finish
(
~loader = FluidLoadFolder(FluidFilesPath()).play; // load the audio (all the files in the FluCoMa audio files folder!)
~slicePoints = Buffer.read(s,FluidFilesPath("../Data/flucoma_corpus_slices.wav")); // load the slice positions of the audio
~ds_mfcc = FluidDataSet(s).read(FluidFilesPath("../Data/flucoma_corpus_mfcc.json")); // load the pre-analyzed dataset
~reduced = FluidDataSet(s);
~umap = FluidUMAP(s,2,15,0.1).fitTransform(~ds_mfcc,~reduced);
~normalizer = FluidNormalize(s).fitTransform(~reduced,~reduced,action:{"done".postln;});
)

(
~reduced.dump{
	arg dict;
	defer{
		~fp = FluidPlotter(dict:dict).addPoint_("current",0.5,0.5,Color.red,2);

		{
			// play the original buffer back, but backwardsa and a little faster for some variety
			var sig = PlayBuf.ar(2,~loader.buffer,-1.3,1,rrand(0,~loader.buffer.numFrames-1),1)[0];
			var mfccs = FluidMFCC.kr(sig,26,startCoeff:1); // get mfcc analyses
			var mfccbuf = LocalBuf(mfccs.numChannels);
			var reducedbuf = LocalBuf(2);
			var normbuf = LocalBuf(2);
			var trig = Impulse.kr(30);
			var xy;
			FluidKrToBuf.kr(mfccs,mfccbuf);
			~umap.kr(trig,mfccbuf,reducedbuf); // project the mfcc analyses into the umap space
			~normalizer.kr(trig,reducedbuf,normbuf); // make sure it's in the normalized space
			xy = FluidBufToKr.kr(normbuf);
			SendReply.kr(trig,"/xy",xy); // send back to the language for plotting
			sig;
		}.play;

		OSCdef(\xy,{
			arg msg;
			defer{
				~fp.setPoint_("current",msg[3],msg[4],Color.red,2); // shows where the current mfcc analysis would be
			};
		},"/xy");
	}
};
)

::
