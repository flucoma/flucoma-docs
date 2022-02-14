
code::
//FluidBufPitch is useful to illustrate the effect of this, because the pitch and confidence values are easily distinguishable

(
~path = FluidFilesPath();
~randomsoundfile = SoundFile.collect(~path +/+ '*').choose;
b = Buffer.read(s,~randomsoundfile.path,action:{"Sound Loaded".postln});
~pitchdata = Buffer.new;
~flatdata = Buffer.new;
)

//Pitch analysis, writes pitches as frequencies to chan 0, confidences [0-1] to chan 1
FluidBufPitch.process(s,b,numFrames:512 * 10,numChans:1,features:~pitchdata,action:{"Pitch Analysis Done".postln});

// Flatten and print the flat buffer. We expect to see larger numbers (20-2000) interleaved with smaller (0-1)
(
FluidBufFlatten.process(s,~pitchdata, destination: ~flatdata, axis:1, action:{
	~flatdata.loadToFloatArray(action:{ |a|
		a.postln;
	})
})
)

//changing the axis, we see all large numbers first
(
FluidBufFlatten.process(s,~pitchdata, destination:~flatdata, axis:0, action:{
	~flatdata.loadToFloatArray(action:{ |a|
		a.postln;
	})
})
)

//adding the source range make this processor very powerful, but can be quite confusing
//here we take only one frame starting at the second one (0-counting)
(
FluidBufFlatten.process(s,~pitchdata,startFrame: 1,numFrames: 1, destination:~flatdata, action:{
	~flatdata.loadToFloatArray(action:{ |a|
		a.postln;
	})
})
)
//and here we take only the confidences
(
FluidBufFlatten.process(s,~pitchdata, startChan: 1, destination:~flatdata, action:{
	~flatdata.loadToFloatArray(action:{ |a|
		a.postln;
	})
})
)

::
