(
// run the analysis
Routine{
	var time = Main.elapsedTime;
	var ds = FluidDataSet(s);
	var labels = FluidLabelSet(s);
	var scaler = FluidStandardize(s);
	var buf1 = Buffer.alloc(s,1);

	~pitch_features_buf = Buffer.new(s);
	// specify some params for the analysis (these are the defaults, but we'll specify them here so we can use them later)
	~windowSize = 4096;
	~hopSize = 512;

	~buf = Buffer.read(s,"/Users/macprocomputer/Desktop/_flucoma/code/flucoma-core-src/AudioFiles/Tremblay-AaS-AcBassGuit-Melo-M.wav");

	s.sync;

	FluidBufPitch.process(s,~buf,features:~pitch_features_buf,windowSize:~windowSize,hopSize:~hopSize).wait;
	~pitch_features_buf.loadToFloatArray(action:{
		arg fa;
		~pitch_features_array = fa.clump(2);
	});
	"FluidBufPitch took % seconds".format(Main.elapsedTime - time).postln;
	~pitch_features_array = ~pitch_features_array.collect({
		arg arr, i;
		arr ++ [i];
	});
	~pitch_features_array = ~pitch_features_array.sort({
		arg a, b;
		a[0] < b[0]
	});

	// In order to granulate the frames, we need to convert our indices to centerPos.
	~selected_center_pos = ~pitch_features_array.collect({arg arr; (arr[2] * ~hopSize) / ~buf.sampleRate});
	~selected_center_pos.postln;
	// Load this list of center positions into a buffer so we can look them up later on the server
	~center_pos_buf = Buffer.loadCollection(s,~selected_center_pos);
}.play
)

(
OSCdef(\fluidbufpitch_help,{
	arg msg;
	msg[3].midiname.postln;
},"/fluidbufpitch_help");

{
	var trig = Impulse.kr(s.sampleRate / ~hopSize);
	//var index = TIRand.kr(0,BufFrames.ir(~center_pos_buf)-1,trig);
	var offset = TIRand.kr(0,BufFrames.ir(~center_pos_buf),Dust.kr(1));
	var index = (PulseCount.kr(trig) - 1 + offset) % BufFrames.ir(~center_pos_buf);
	var centerPos = Index.kr(~center_pos_buf,index);
	var pan = TRand.kr(-1.0,1.0,trig);
	var sig;
	var pitch, conf;
	// index.poll;
	sig = TGrains.ar(2,trig,~buf,BufRateScale.ir(~buf),centerPos,~windowSize / BufSampleRate.ir(~buf),pan,0.5);
	# pitch, conf = FluidPitch.kr(sig,unit:1,windowSize:4096);
	pitch = FluidStats.kr(pitch,25)[0];
	SendReply.kr(Impulse.kr(30) * (conf > 0.6),"/fluidbufpitch_help",pitch);
	sig;
}.play;
)