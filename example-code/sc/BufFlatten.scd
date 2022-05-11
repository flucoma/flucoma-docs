strong::Using FluidBufFlatten for adding points to a FluidDataSet::
code::

(
~buf = Buffer.readChannel(s,FluidFilesPath("Tremblay-CEL-GlitchyMusicBoxMelo.wav"),channels:[0]);
~chromabuf = Buffer(s); // buffer for storing chroma analysis
~statsbuf = Buffer(s); // buffer for storing statistical analysis of chroma analysis
~flatbuf = Buffer(s); // buffer for storing the flattened data of the mean chroma values
~chroma_ds = FluidDataSet(s); // dataset for writing points into
)

(
fork{
	~n_analysis_frames = ~buf.sampleRate * 0.1; // analyze in 0.1 second windows
	~current_analysis_frame = 0; // start at 0
	i = 0;
	while({
		// while the next frame that we would analyze doesn't go past the end of the buffer
		(~current_analysis_frame + ~n_analysis_frames) < ~buf.numFrames;
	},{
		// do the chroma analysis on this section of the buffer. this will return a buffer of 12 channels (one for each chroma)
		// with as many frames as there are FFT windows in the 0.1 second slice we're analysing
		FluidBufChroma.processBlocking(s,~buf,~current_analysis_frame,~n_analysis_frames,features:~chromabuf);

		// next, perform statistical analysis on each channel in chromabuf. this will return a buffer with however many
		// channels are in chromabuf (12) and 7 frames, one for each statistical analysis
		FluidBufStats.processBlocking(s,~chromabuf,stats:~statsbuf);

		// finally, since we want to have the mean value for each of the chroma we can ask FluidBufFlatten to just
		// process the 0th frame (that has the mean values) of all the channels (so just the 0th column) into a flat
		// buffer so it can be used in FluidDataSet.addPoint
		FluidBufFlatten.processBlocking(s,~statsbuf,numFrames:1,destination:~flatbuf);
		~chroma_ds.addPoint("point-%".format(i),~flatbuf);

		~current_analysis_frame = ~current_analysis_frame + ~n_analysis_frames;
		i = i + 1;
	});
	s.sync;
	"                   \t\tnumFrames\tnumChannels".postln;
	"shape of chromabuf:\t\t%\t\t\t%".format(~chromabuf.numFrames,~chromabuf.numChannels).postln;
	"shape of statsbuf: \t\t%\t\t\t%".format(~statsbuf.numFrames,~statsbuf.numChannels).postln;
	"shape of flatbuf:  \t\t%\t\t\t%\n".format(~flatbuf.numFrames,~flatbuf.numChannels).postln;
	~chroma_ds.print;
}
)
::
strong::FluidBufPitch is useful to illustrate the effect of this, because the pitch and confidence values are easily distinguishable::
code::
(
~buf = Buffer.readChannel(s,FluidFilesPath("Tremblay-CEL-GlitchyMusicBoxMelo.wav"),channels:[0]);
~pitchdata = Buffer(s);
~flatdata = Buffer(s);
)

//Pitch analysis, writes pitches as frequencies to chan 0, confidences [0-1] to chan 1
// we'll only analyze the first 10 frames here so we can visually inspect the data more easily
FluidBufPitch.processBlocking(s,~buf,numFrames:512 * 9,numChans:1,features:~pitchdata,action:{"Pitch Analysis Done".postln});

//plot the original buffer to get a sense of what is in it:
(
"numFrames:   %".format(~pitchdata.numFrames).postln;
"numChannels: %".format(~pitchdata.numChannels).postln;
~pitchdata.plot(separately:true);
)

// Flatten and print the flat buffer. We expect to see larger numbers (20-2000) interleaved with smaller (0-1)
(
FluidBufFlatten.process(s,~pitchdata, destination: ~flatdata, axis:1, action:{
	~flatdata.loadToFloatArray(action:{ |a|
		"numFrames:   %".format(~flatdata.numFrames).postln;
		"numChannels: %".format(~flatdata.numChannels).postln;
		a.postln;
	})
})
)

//changing the axis, we see all large numbers first
(
FluidBufFlatten.process(s,~pitchdata, destination:~flatdata, axis:0, action:{
	~flatdata.loadToFloatArray(action:{ |a|
		"numFrames:   %".format(~flatdata.numFrames).postln;
		"numChannels: %".format(~flatdata.numChannels).postln;
		a.postln;
	})
})
)

//adding the source range (startFrame and numFrames) make this processor very powerful
//here we take only one frame starting at the second one (0-counting)
(
FluidBufFlatten.process(s,~pitchdata,startFrame: 1,numFrames: 1, destination:~flatdata, action:{
	~flatdata.loadToFloatArray(action:{ |a|
		"numFrames:   %".format(~flatdata.numFrames).postln;
		"numChannels: %".format(~flatdata.numChannels).postln;
		a.postln;
	})
})
)

//and here we take only the confidences
(
FluidBufFlatten.process(s,~pitchdata, startChan: 1, destination:~flatdata, action:{
	~flatdata.loadToFloatArray(action:{ |a|
		"numFrames:   %".format(~flatdata.numFrames).postln;
		"numChannels: %".format(~flatdata.numChannels).postln;
		a.postln;
	})
})
)
::