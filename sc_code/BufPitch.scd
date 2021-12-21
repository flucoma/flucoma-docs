// ================= A MUSICAL EXAMPLE =========================

(
// load a sound file
~buf = Buffer.read(s,File.realpath(FluidBufPitch.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-ASWINE-ScratchySynth-M.wav");
// and a buffer to write the FluidBufPitch features into
~pitch_features_buf = Buffer.new(s);
// specify some params for the analysis (these are the defaults, but we'll specify them here so we can use them later)
~windowSize = 1024;
~hopSize = 512;
)

(
// run the analysis
Routine{
	var time = Main.elapsedTime;
	FluidBufPitch.process(s,~buf,features:~pitch_features_buf,windowSize:~windowSize,hopSize:~hopSize).wait;
	~pitch_features_buf.loadToFloatArray(action:{
		arg fa;
		~pitch_features_array = fa.clump(2);
	});
	"FluidBufPitch took % seconds".format(Main.elapsedTime - time).postln;
}.play
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
~selected_center_pos = ~selected_indices.collect({arg i; (i * ~hopSize) / ~buf.sampleRate});
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
	sig = TGrains.ar(2,trig,~buf,BufRateScale.ir(~buf),centerPos,~windowSize / BufSampleRate.ir(~buf),pan,0.5);
	sig;
}.play;
)

// ================= A DIDACTING TEST EXAMPLE ================

// create a buffer with a short clicking sinusoidal burst (220Hz) starting at frame 8192 for 1024 frames
(
b = Buffer.sendCollection(s, (Array.fill(8192,{0}) ++ (Signal.sineFill(1203,[0,0,0,0,0,1],[0,0,0,0,0,0.5pi]).takeThese({|x,i|i>1023})) ++ Array.fill(8192,{0})));
c = Buffer.new(s);
)

// listen to the source and look at the buffer
b.play; b.plot;

// run the process with basic parameters
(
Routine{
	t = Main.elapsedTime;
	FluidBufPitch.process(s, b, features: c).wait;
	(Main.elapsedTime - t).postln;
}.play
)

// look at the analysis
c.plot(separately:true)

// The values are interleaved [pitch,confidence] in the buffer as they are on 2 channels: to get to the right frame, divide the SR of the input by the hopSize, then multiply by 2 because of the channel interleaving
// here we are querying from one frame before (the signal starts at 8192, which is frame 16 (8192/512), therefore starting the query at frame 15, which is index 30.
c.getn(30,10,{|x|x.postln})

// observe that the first frame is silent, as expected. The next frame's confidence is low-ish, because the window is half full (window of 1024, overlap of 512). Then a full window is analysed, with strong confidence. Then another half full window, then silence, as expected.

// ================== A STEREO BUFFER EXAMPLE =====================

// load two very different files
(
b = Buffer.read(s,File.realpath(FluidBufPitch.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-SA-UprightPianoPedalWide.wav");
c = Buffer.read(s,File.realpath(FluidBufPitch.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-AcousticStrums-M.wav");
)

// composite one on left one on right as test signals
FluidBufCompose.process(s, c, numFrames:b.numFrames, startFrame:555000,destStartChan:1, destination:b)
b.play

// create a buffer as destinations
c = Buffer(s);

//run the process on them, with limited bandwidth and units in MIDI notes
(
Routine{
	t = Main.elapsedTime;
	FluidBufPitch.process(s, b, features: c, minFreq:200, maxFreq:2000, unit:1).wait;
	(Main.elapsedTime - t).postln;
}.play
)

// look at the buffer: [pitch,confidence] for left then [pitch,confidence] for right
c.plot(separately:true)