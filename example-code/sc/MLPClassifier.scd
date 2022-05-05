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
strong::Training-Testing Split::
code::

// two audio buffers to use as separate classes
(
~buffers = [
	Buffer.readChannel(s,FluidFilesPath("Tremblay-AaS-AcBassGuit-Melo-M.wav"),channels:[0]),
	Buffer.readChannel(s,FluidFilesPath("Tremblay-CEL-GlitchyMusicBoxMelo.wav"),channels:[0])
];
)

// strip any silence
(
fork{
	~buffers = ~buffers.collect{
		arg src;
		var indices = Buffer(s);
		var temp = Buffer(s);
		FluidBufAmpGate.processBlocking(s,src,indices:indices,onThreshold:-30,offThreshold:-35,minSliceLength:4410);
		indices.loadToFloatArray(action:{
			arg fa;
			var curr = 0;
			fa.clump(2).do{
				arg arr;
				var start = arr[0];
				var num = arr[1] - start;
				FluidBufCompose.processBlocking(s,src,start,num,destination:temp,destStartFrame:curr);
				curr = curr + num;
			};
			indices.free;
			src.free;
		});
		temp;
	};
	s.sync;
	"done stripping silence".postln;
}
)

// take a look to see that the silence is stripped
(
~win = Window("FluidWaveform Test",Rect(0,0,1000,500));
~fws = ~buffers.collect{arg buf; FluidWaveform(buf, standalone: false)};
~win.view.layout = VLayout(~fws[0], ~fws[1]);
~win.front;
)

// analysis
(
fork{
	var features = Buffer(s);
	var flat = Buffer(s);
	var counter = 0;
	~trainingData = FluidDataSet(s);
	~trainingLabels = FluidLabelSet(s);
	~testingData = FluidDataSet(s);
	~testingLabels = FluidLabelSet(s);

	~buffers.do{
		arg buf, buffer_i;
		FluidBufMFCC.processBlocking(s,buf,features:features,startCoeff:1);
		s.sync;
		features.numFrames.do{
			arg i;
			var id = "analysis-%".format(counter);
			FluidBufFlatten.processBlocking(s,features,i,1,destination:flat);
			if(0.8.coin){ // randomly: 80% of the time add to training data, 20% add to testing data
				~trainingData.addPoint(id,flat);
				~trainingLabels.addLabel(id,buffer_i);
			}{
				~testingData.addPoint(id,flat);
				~testingLabels.addLabel(id,buffer_i);
			};
			counter = counter + 1;
		};
	};

	s.sync;

	~trainingData.print;
	~trainingLabels.print;
	~testingData.print;
	~testingLabels.print;
};
)

// train!
(
~mlp = FluidMLPClassifier(s,[7],activation:FluidMLPClassifier.sigmoid,maxIter:100,learnRate:0.01,batchSize:1,validation:0.1);

~mlp.fit(~trainingData,~trainingLabels,{
	arg error;
	"current error: % ".format(error).postln;
});
)

// test!
(
~predictions = FluidLabelSet(s);
~mlp.predict(~testingData,~predictions,{
	~predictions.dump({
		arg yhat;
		~testingLabels.dump({
			arg labels;
			var wrong = 0;
			labels["data"].keysValuesDo{
				arg k, v;
				var label = v[0];
				var pred = yhat["data"][k][0];
				"id: %\t\tlabel: %\t\tprediction: %".format(k.padRight(14),label,pred).post;
				if(pred != label){
					"\t\t* wrong".post;
					wrong = wrong + 1;
				};
				"".postln;
			};
			"% / % were predicted incorrectly".format(wrong,labels["data"].size).postln;
		});
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
