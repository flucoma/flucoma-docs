strong::Real-Time Tweaking Parameters::
code::

s.boot;

// some audio files to classify
(
~tbone = Buffer.read(s,FluidFilesPath("Olencki-TenTromboneLongTones-M.wav"),27402,257199);
~oboe = Buffer.read(s,FluidFilesPath("Harker-DS-TenOboeMultiphonics-M.wav"),27402,257199);
)

// listen to these short bits
~tbone.play;
~oboe.play;

// create a dataSet of pitch and pitch confidence analyses (and normalize them)
(
~dataSet = FluidDataSet(s);
~labelSet = FluidLabelSet(s);
~pitch_features = Buffer(s);
~point = Buffer(s);
[~tbone,~oboe].do{
	arg src, instr_id;
	FluidBufPitch.processBlocking(s,src,features:~pitch_features,windowSize:2048);
	252.do{ // I happen to know there are 252 frames in this buffer
		arg idx;
		var id = "slice-%".format((instr_id*252)+idx);
		var label = ["trombone","oboe"][instr_id];
		FluidBufFlatten.processBlocking(s,~pitch_features,idx,1,destination:~point);
		~dataSet.addPoint(id,~point);
		~labelSet.addLabel(id,label);
	};
};
FluidNormalize(s).fitTransform(~dataSet,~dataSet);
~dataSet.print;
~labelSet.print;
)

(
// take a look if you want: quite clear separation for the neural network to learn (blue will be trombone and orange will be oboe)
~dataSet.dump({
	arg datadict;
	~labelSet.dump({
		arg labeldict;
		defer{
			FluidPlotter(dict:datadict).categories_(labeldict);
		};
	});
});
)

(
// make a neural network
~mlp = FluidMLPClassifier(s,[3],activation:FluidMLPClassifier.sigmoid,maxIter:20,learnRate:0.01,batchSize:1,validation:0.1);

// make a flag that can later be set to false
~continuous_training = true;

// a recursive function for training
~train = {
	~mlp.fit(~dataSet,~labelSet,{
		arg error;
		"current error: % ".format(error.asStringff(5)).post;
		{"*".post;} ! (error*100).asInteger;
		"".postln;
		if(~continuous_training){~train.()}
	});
};

// start training
~train.();
)

// you can make adjustments while it's recursively calling itself:
~mlp.learnRate_(0.02);  // won't reset the neural network
~mlp.batchSize_(2);     // won't reset the neural network
~mlp.maxIter_(50);      // won't reset the neural network
~mlp.validation_(0.05); // won't reset the neural network
~mlp.momentum_(0.95);   // won't reset the neural network

~mlp.hidden_([2]);                         // *will* reset the neural network
~mlp.activation_(FluidMLPClassifier.tanh); // *will* reset the neural network

// when the loss has decreased and then leveled out, stop the recursive training:
~continuous_training = false;

// make some predictions
(
~predictions = FluidLabelSet(s);
~mlp.predict(~dataSet,~predictions);
~predictions.dump({
	arg predictions;
	~labelSet.dump({
		arg labels;
		var wrong = 0;
		var total = predictions["data"].size;
		labels["data"].keysValuesDo{
			arg k, v;
			var label = v[0];
			var prediction = predictions["data"][k][0];
			"key: %\t\tlabel: %\t\tprediction: %".format(k,label.padRight(8),prediction.padRight(8)).post;
			if(label != prediction){
				wrong = wrong + 1;
				"\t\t* wrong".post;
			};
			"".postln;
		};

		"\n% wrong / % total".format(wrong,total).postln;
		"% percent correct".format(((1-(wrong/total)) * 100).round(0.01)).postln;
		"of course it should get most all these correct, this is the data it trained on!".postln;
	});
});
)
::
strong::Predict classes entirely on the server::
code::
~mlp = FluidMLPClassifier(s);

// load a model that has been pre-trained to classify between a tone and noise, simple, i know, but...
~mlp.read(FluidFilesPath("../../Resources/bufToKrExample.json"));

// can be used to demonstrate that...
(
{
    var input_buf = LocalBuf(7);
    var out_buf = LocalBuf(1);
    var sig = Select.ar(ToggleFF.kr(Dust.kr(1)),[SinOsc.ar(440),PinkNoise.ar]);
    var analysis = FluidSpectralShape.kr(sig);
    FluidKrToBuf.kr(analysis,input_buf);

    // the output prediction is written into a buffer
    ~mlp.kr(Impulse.kr(30),input_buf,out_buf);

    // and FluidBufToKr can be used to read the prediction out into a control rate stream
    FluidBufToKr.kr(out_buf).poll;

    sig.dup * -30.dbamp
}.play;
)
::
