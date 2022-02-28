
code::
(
// load a sound file
~scratchy = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));
// and a buffer to write the FluidBufPitch features into
~pitch_features_buf = Buffer.new(s);
// specify some params for the analysis (these are the defaults, but we'll specify them here so we can use them later)
~windowSize = 1024;
~hopSize = 512;
)

(
// run the analysis
FluidBufPitch.processBlocking(s,~scratchy,features:~pitch_features_buf,windowSize:~windowSize,hopSize:~hopSize);
~pitch_features_buf.loadToFloatArray(action:{
	arg fa;
	~pitch_features_array = fa.clump(2);
});
)

//look at the retrieved formatted array of [pitch,confidence] values
~pitch_features_array.postln

//iterate and make an array of the indices which are fitting the conditions
(
~selected_indices = List.new;
~pitch_features_array.do({
	arg val, i;
	// if pitch is greater than 500Hz and confidence higher than 0.98, add the index to the list
	if((val[0] > 500) && (val[1] > 0.98),{
		~selected_indices.add(i);
	});
});
~selected_indices.postln;
)

(
// In order to granulate the frames, we need to convert our indices to centerPos.
~selected_center_pos = ~selected_indices.collect({arg i; (i * ~hopSize) / ~scratchy.sampleRate});
~selected_center_pos.postln;
// Load this list of center positions into a buffer so we can look them up later on the server
~center_pos_buf = Buffer.loadCollection(s,~selected_center_pos);
)

(
// Randomly create indices for the buffer and use them to look up center positions for TGrains.ar
{
	var trig = Impulse.kr(s.sampleRate / ~hopSize);
	var index = TIRand.kr(0,BufFrames.ir(~center_pos_buf)-1,trig);
	var centerPos = Index.kr(~center_pos_buf,index);
	var pan = TRand.kr(-1.0,1.0,trig);
	var sig;
	sig = TGrains.ar(2,trig,~scratchy,BufRateScale.ir(~scratchy),centerPos,~windowSize / BufSampleRate.ir(~scratchy),pan,0.5);
	sig;
}.play;
)
::

STRONG::A stereo buffer example.::
CODE::
// load two very different files
(
~piano = Buffer.read(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"));
~guitar = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcousticStrums-M.wav"));
~both = Buffer(s);
)

// composite one on left one on right as test signals
FluidBufCompose.processBlocking(s,~piano, destination:~both,action:{"done".postln});
FluidBufCompose.processBlocking(s,~guitar,numFrames:~piano.numFrames,startFrame:555000,destStartChan:1,destination:~both,action:{"done".postln});

// listen
~both.play

// create a buffer as destinations
~pitch_analysis = Buffer(s);

//run the process on them, with limited bandwidth
FluidBufPitch.process(s, ~both, features: ~pitch_analysis, minFreq:60, maxFreq:4000,action:{"done".postln});

// look at the buffer: [pitch,confidence] for left then [pitch,confidence] for right
FluidWaveform(~both,featureBuffer:~pitch_analysis,stackFeatures:true,bounds:Rect(0,0,1600,400));

// blue is piano pitch
// orange is piano pitch confidence
// green is guitar pitch
// red is guitar pitch confidence

::
