strong::Control a multi-parameter Synth from a 2D space::
code::

/*

1. Run block of code 1 to make some datasets and buffers for interfacing with the neural network
2. Run block of code 2 to make the actual synth that we'll be controlling
3. Run block of code 3 to make the GUI that will let us (a) add input-output example pairs, (b) use those
example pairs to train the neural network, and (c) make predictions with the neural network
4. Use the multislider to change the synthesis parameters to a sound you like
5. Choose a position in the 2D slider where you want this sound to be placed.
6. Now that you have your input (2D position) paired with you output (multislider positions), click
"Add Points" to add these to their respective data sets.
7. Repeat steps 4-6 about 5 times. Make sure to keep moving the 2D slider to new positions for each sound.
8. Train the neural network by hitting "Train" a bunch of times. For this task you can probably aim to get
the "loss" down around 0.001.
9. Hit the "Not Predicting" toggle so that it turns into predicting mode and start moving around the 2D slider!

*/

// 1. datasets and buffers for interfacing with the neural network
(
~ds_input = FluidDataSet(s);
~ds_output = FluidDataSet(s);
~x_buf = Buffer.alloc(s,2);
~y_buf = Buffer.loadCollection(s,{rrand(0.0,1.0)} ! 10);
~nn = FluidMLPRegressor(s,[7],FluidMLPRegressor.sigmoid,FluidMLPRegressor.sigmoid,learnRate:0.1,batchSize:1,validation:0);
)

// 2. the synth that we'll be contorlling (has 10 control parameters, expects them to be between 0 and 1)
(
~synth = {
	var val = FluidBufToKr.kr(~y_buf);
	var osc1, osc2, feed1, feed2, base1=69, base2=69, base3 = 130;
	#feed2,feed1 = LocalIn.ar(2);
	osc1 = MoogFF.ar(SinOsc.ar((((feed1 * val[0]) +  val[1]) * base1).midicps,mul: (val[2] * 50).dbamp).atan,(base3 - (val[3] * (FluidLoudness.kr(feed2,kWeighting: 1,truePeak: 0, hopSize: 64)[0].clip(-120,0) + 120))).lag(128/44100).midicps, val[4] * 3.5);
	osc2 = MoogFF.ar(SinOsc.ar((((feed2 * val[5]) +  val[6]) * base2).midicps,mul: (val[7] * 50).dbamp).atan,(base3 - (val[8] * (FluidLoudness.kr(feed1, kWeighting:1,truePeak: 0, hopSize: 64)[0].clip(-120,0) + 120))).lag(128/44100).midicps, val[9] * 3.5);
	Out.ar(0,LeakDC.ar([osc1,osc2],mul: 0.1));
	LocalOut.ar([osc1,osc2]);
}.play;
)

// 3. a gui for creating input-output example pairs, then training, and then making predicitons.
(
~counter = 0;
~predicting = false;
~prediction_buf = Buffer.alloc(s,10);
~win = Window("MLP Regressor",Rect(0,0,1000,400));

~multisliderview = MultiSliderView(~win,Rect(0,0,400,400))
.size_(10)
.elasticMode_(true)
.action_({
	arg msv;
	~y_buf.setn(0,msv.value);
});

Slider2D(~win,Rect(400,0,400,400))
.action_({
	arg s2d;
	[s2d.x,s2d.y].postln;
	~x_buf.setn(0,[s2d.x,s2d.y]); // put the x position directly into the buffer
	if(~predicting,{
		~nn.predictPoint(~x_buf,~y_buf,{

			// the synth actually reads directly out of the ~y_buf, but here we get it back to the language so we can display
			// it in the multislider
			~y_buf.getn(0,10,{
				arg prediction_values;
				{~multisliderview.value_(prediction_values)}.defer;
			});
		});
	});
});

Button(~win,Rect(800,0,200,20))
.states_([["Add Points"]])
.action_({
	arg but;
	var id = "example-%".format(~counter);
	~ds_input.addPoint(id,~x_buf);
	~ds_output.addPoint(id,~y_buf);
	~counter = ~counter + 1;

	~ds_input.print;
	~ds_output.print;
});

Button(~win,Rect(800,20,200,20))
.states_([["Train"]])
.action_({
	arg but;
	~nn.fit(~ds_input,~ds_output,{
		arg loss;
		"loss: %".format(loss).postln;
	});
});

Button(~win,Rect(800,40,200,20))
.states_([["Not Predicting",Color.yellow,Color.black],["Is Predicting",Color.green,Color.black]])
.action_({
	arg but;
	~predicting = but.value.asBoolean;
});

~win.front;
)
::
strong::Making Predicitons on the Server (Predicting Frequency Modulation parameters from MFCC analyses)::
code::

(
~inputs = FluidDataSet(s);
~outputs = FluidDataSet(s);
~analysis_buf = Buffer.alloc(s,13);
~params_buf = Buffer.loadCollection(s,[800,300,3]); // some inital parameters to hear it turn on
)

// for playing the fm and getting the data
(
~synth = {
	var params = FluidBufToKr.kr(~params_buf,numFrames:3); // get the synth params out of the buffer
	var sig = SinOsc.ar(params[0] + SinOsc.ar(params[1],0,params[1]*params[2]),0,-40.dbamp); // fm synthesis
	var analysis = FluidMFCC.kr(sig,13,startCoeff:1); // get the mfcc analysis of the sound
	FluidKrToBuf.kr(analysis,~analysis_buf,krNumChans:13); // write it into a buffer
	sig.dup;
}.play;
)

// add 100 input-output example pairs
(
fork{
	100.do{
		arg i;
		var cfreq = exprand(60,2000);
		var mfreq = rrand(30.0,cfreq);
		var index = rrand(0.0,20.0);
		var params = [cfreq,mfreq,index];
		~params_buf.setn(0,params);
		s.sync;
		~outputs.addPoint(i,~params_buf);
		0.1.wait;
		~inputs.addPoint(i,~analysis_buf);
		0.1.wait;

		"adding point: %\tparams: %".format(i.asStringff(3),params).postln;
	};

	~in_scaler = FluidNormalize(s).fitTransform(~inputs,~inputs);
	~out_scaler = FluidNormalize(s).fitTransform(~outputs,~outputs);

	s.sync;

	~synth.free;
}
)

// train
(
~mlp = FluidMLPRegressor(s,[8],FluidMLPRegressor.sigmoid,FluidMLPRegressor.sigmoid,maxIter:100,learnRate:0.1,batchSize:5,validation:0.1);
~continuously_train = true;
~train = {
	~mlp.fit(~inputs,~outputs,{
		arg error;
		"current error: % ".format(error.round(0.0001)).post;
		{"*".post} ! (error * 100).asInteger;
		"".postln;
		if(~continuously_train){~train.()};
	});
};
~train.();
)

// tweak some params during the training maybe:
~mlp.validation_(0.1);
~mlp.learnRate_(0.01);
~mlp.maxIter_(10);
~mlp.batchSize_(1);
~mlp.hiddenLayers_([10,5]);

// once it levels out:
~continuously_train = false;

~musicbox = Buffer.readChannel(s,FluidFilesPath("Tremblay-CEL-GlitchyMusicBoxMelo.wav"),channels:[0]);

// see how it fares, use the mouse to hear the balance
(
~synth = {
	arg test_buf;
	var test_sig = PlayBuf.ar(1,test_buf,BufRateScale.kr(test_buf),loop:1);
	var test_sig_loudness = FluidLoudness.kr(test_sig)[0];
	var mfccs = FluidMFCC.kr(test_sig,13,startCoeff:1);
	var mfcc_buf = LocalBuf(13);
	var mfcc_buf_scaled = LocalBuf(13);
	var prediction = LocalBuf(3);
	var prediction_scaled = LocalBuf(3);
	var trig = Impulse.kr(30);
	var params, sig;
	mfccs = FluidStats.kr(mfccs,20)[0];
	FluidKrToBuf.kr(mfccs,mfcc_buf);
	~in_scaler.kr(trig,mfcc_buf,mfcc_buf_scaled);
	~mlp.kr(trig,mfcc_buf_scaled,prediction);
	~out_scaler.kr(trig,prediction,prediction_scaled,invert:1);
	params = FluidBufToKr.kr(prediction_scaled);
	sig = SinOsc.ar(params[0] + SinOsc.ar(params[1],0,params[1]*params[2]),0,test_sig_loudness.dbamp);
	[test_sig * (1-MouseX.kr),sig * MouseX.kr];
}.play(args:[\test_buf,~musicbox]);
)

~oboe = Buffer.readChannel(s,FluidFilesPath("Harker-DS-TenOboeMultiphonics-M.wav"),channels:[0]);
~synth.set(\test_buf,~oboe);

~tbone = Buffer.readChannel(s,FluidFilesPath("Olencki-TenTromboneLongTones-M.wav"),channels:[0]);
~synth.set(\test_buf,~tbone);

~voice = Buffer.readChannel(s,FluidFilesPath("Tremblay-AaS-VoiceQC-B2K-M.wav"),channels:[0]);
~synth.set(\test_buf,~voice);

~drums = Buffer.readChannel(s,FluidFilesPath("Nicol-LoopE-M.wav"),channels:[0]);
~synth.set(\test_buf,~drums);

::
strong::Using an Autoencoder to Create a Latent Space of Wavetables::
code::
// thansk to Timo Hoogland for the inspiration!

// boot the server
s.boot;

// the source material wavetables will come from here (also try out other soundfiles!)
~buf = Buffer.read(s,FluidFilesPath("Olencki-TenTromboneLongTones-M.wav"));

// remove the silent parts of the buffer
(
var indices = Buffer(s);
FluidBufAmpGate.processBlocking(s,~buf,indices:indices,onThreshold:-30,offThreshold:-40,minSliceLength:0.1*s.sampleRate,minSilenceLength:0.1*s.sampleRate,rampDown:0.01*s.sampleRate);
indices.loadToFloatArray(action:{
	arg fa;
	var current_frame = 0;
	var temp = Buffer(s);
	fa = fa.clump(2);
	fa.do{
		arg arr, i;
		var startFrame = arr[0];
		var numFrames = arr[1] - startFrame;
		FluidBufCompose.processBlocking(s,~buf,startFrame,numFrames,destination:temp,destStartFrame:current_frame);
		current_frame = current_frame + numFrames;
	};
	s.sync;
	indices.free;
	~buf = temp;
	"silence removed".postln;
});
)

// make a dataset comprised of points that are ~winSize samples long
(
~winSize = 3000; // has to be somewhat long otherwise it can't represent lower frequencies
fork{
	var bufWin = Buffer(s);
	var currentFrame = 0;
	var counter = 0;

	~ds = FluidDataSet(s);

	while({
		(currentFrame + ~winSize) < ~buf.numFrames;
	},{
		FluidBufCompose.processBlocking(s,~buf,currentFrame,~winSize,destination:bufWin);
		~ds.addPoint(counter,bufWin);
		"% / %".format(currentFrame.asString.padLeft(10),~buf.numFrames.asString.padLeft(10)).postln;
		if((counter % 100) == 99){s.sync};
		counter = counter + 1;
		currentFrame = currentFrame + ~winSize;
	});
	bufWin.free;
	"done".postln;
}
)

// take a look at it
~ds.print;

// use PCA to reduce the number of dimensions from the length of the wavetable to something smaller (this will take a second to process!)
(
~ds_pca = FluidDataSet(s);
~pca = FluidPCA(s,60);
~pca.fitTransform(~ds,~ds_pca,{
	arg variance;
	variance.postln;
});
)

// take a look at it
~ds_pca.print;

// train the autoencoder using the PCA-ed data
(
~nn_shape = [40,20,2,20,40];
~ae = FluidMLPRegressor(s,~nn_shape,FluidMLPRegressor.relu,FluidMLPRegressor.identity,learnRate:0.1,maxIter:10,validation:0.2);
~ae.tapOut_(-1);
~continuous = true;
~train = {
	~ae.fit(~ds_pca,~ds_pca,{
		arg loss;
		loss.postln;
		if(~continuous,{~train.()});
	});
};
~train.();
)

// tweak the learning rate
~ae.learnRate_(0.01);
~ae.learnRate_(0.001);

// turn off continuous training
~continuous = false;

// plot it
(
var ds_predict = FluidDataSet(s);
var ds_predict_norm = FluidDataSet(s);
var norm2D = FluidNormalize(s);
var buf2D_norm = Buffer.alloc(s,2);
var buf2D = Buffer.alloc(s,2);
var buf_pca_point = Buffer.alloc(s,~pca.numDimensions);
var buf_pca_point_norm = Buffer.alloc(s,~pca.numDimensions);
var wave = Buffer.alloc(s,~winSize);

// get the latent space
~ae.tapIn_(0).tapOut_((~nn_shape.size+1)/2); // set the "output" of the neural network to be the latent space in the middle
~ae.predict(~ds_pca,ds_predict,{"prediction done".postln;}); // 2D latent space is now in the ds_predict dataset

// normalize it for plotting
norm2D.fitTransform(ds_predict,ds_predict_norm);

~ae.tapIn_((~nn_shape.size+1)/2); // now set the "input" of the neural network to be the latent space in the middle
~ae.tapOut_(-1); // set the output of the neural network to be the end
ds_predict_norm.dump({
	arg dict;
	fork({
		var win = Window("Autoencoder Wavetable",Rect(0,0,1024,700));
		var ms = MultiSliderView(win,Rect(0,600,1024,100));
		ms.elasticMode_(true);
		ms.reference_(0.5);
		ms.drawRects_(false);
		ms.drawLines_(true);

		// this is the synth that will play back the wavetable with an overlap of 4
		{
			var n = 4;
			var rate = 1;
			var phs = Phasor.ar(0,rate,0,BufFrames.kr(wave));
			var phss = n.collect{
				arg i;
				var p = phs + ((BufFrames.kr(wave) / n) * i);
				p % (BufFrames.kr(wave));
			};
			var sig = BufRd.ar(1,wave,phss,1,4);
			var env = EnvGen.ar(Env([0,1,0],[SampleDur.ir * ~winSize * 0.5].dup,\sin),phss > 0.5,timeScale:rate.reciprocal);
			sig = sig * env;
			Mix(sig).dup;
		}.play;

		// the plotter accepts mouse clicks and drags
		FluidPlotter(win,bounds:Rect((win.bounds.width-600) / 2,0,600,600),dict:dict,mouseMoveAction:{
			arg view, x, y;
			buf2D_norm.setn(0,[x,y]); // put current position into this buffer
			norm2D.inverseTransformPoint(buf2D_norm,buf2D); // transform the point back to the unnormalized dimensions
			~ae.predictPoint(buf2D,buf_pca_point); // use that to make a prediction from the 2D latent space back to the PCA space
			~pca.inverseTransformPoint(buf_pca_point,wave); // transform the value in PCA space back to the length of the wavetable
			wave.loadToFloatArray(action:{ // the wavetable is already on the server and playing, here we load it back just to display;
				arg fa;
				if(fa.size > 0,{
					defer{ms.value_(fa.resamp1(win.bounds.width).linlin(-1,1,0,1))};
				});
			});
		});

		win.front;
	},AppClock);
});
)
::
