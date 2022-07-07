code::

// load a sound
~buf = Buffer.read(s,FluidFilesPath("Harker-DS-TenOboeMultiphonics-M.wav"));

// do a FluidBufMFCC analysis
(
~mfccs = Buffer(s);
FluidBufMFCC.processBlocking(s,~buf,features:~mfccs,action:{"done".postln;})
)

// plot it in FluidWaveform -- it's not *too* informative, but may be useful to get a sense of what these MFCC curves look like
FluidWaveform(~buf,featuresBuffer:~mfccs,stackFeatures:true,bounds:Rect(0,0,1600,400));

::
strong::Load a lot of MFCC analyses to a data set for later data processing::
code::

// load a sound
~buf = Buffer.readChannel(s,FluidFilesPath("Tremblay-CF-ChurchBells.wav"),channels:[0]);

// do a FluidBufMFCC analysis
(
~mfccs = Buffer(s);
FluidBufMFCC.processBlocking(s,~buf,features:~mfccs,action:{"done".postln;})
)

// create a dataset to put the mfccs in
(
~ds = FluidDataSet(s).fromBuffer(~mfccs);
~ds.print;
)

// dimensionally reduce the 13 MFCCs into 2D space
( // this will take a bit of time to process!
fork{
	~umap = FluidUMAP(s);
	~norm = FluidNormalize(s);
	s.sync;
	~umap.fitTransform(~ds,~ds);
	~norm.fitTransform(~ds,~ds);
	~dict = ~ds.dump({
		arg dict;
		defer{
			FluidPlotter(bounds:Rect(0,0,800,800),dict:dict);
		};
	});
};
)

::