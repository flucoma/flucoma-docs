strong::Using MFCC analyses to classify between bells and piano::
code::

(
// source sounds
~bells = Buffer.readChannel(s,FluidFilesPath("Tremblay-CF-ChurchBells.wav"),channels:[0]);
~piano = Buffer.readChannel(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"),channels:[0]);

// split into a trainging set (~80% of the data) and testing set (~20% of the data)
// for more info about the training-testing split, visit https://learn.flucoma.org/learn/training-testing-split
~train_ds = FluidDataSet(s);
~train_ls = FluidLabelSet(s);
~test_ds = FluidDataSet(s);
~test_ls = FluidLabelSet(s);
)

// analyse
(
fork{
	var mfccbuf = Buffer(s);
	var flatbuf = Buffer(s);
	[~bells,~piano].do{
		arg buf;
		var label = PathName(buf.path).fileNameWithoutExtension;
		FluidBufMFCC.processBlocking(s,buf,features:mfccbuf,startCoeff:1);
		s.sync;
		mfccbuf.numFrames.do{
			arg i;
			var id = "%-%".format(label,i);
			FluidBufFlatten.processBlocking(s,mfccbuf,i,1,destination:flatbuf);

			// about 80% of the data points will end up in the training data,
			// about 20% of the data points will end up in the testing data
			if(0.8.coin){
				~train_ds.addPoint(id,flatbuf);
				~train_ls.addLabel(id,label);
			}{
				~test_ds.addPoint(id,flatbuf);
				~test_ls.addLabel(id,label);
			};
		};
	};
	mfccbuf.free;
	flatbuf.free;
	~train_ds.print;
	~train_ls.print;
	~test_ds.print;
	~test_ls.print;
}
)

// fit the KNNClassifier and make predictions
(
~classifier = FluidKNNClassifier(s).fit(~train_ds,~train_ls);
~predictions_ls = FluidLabelSet(s);
~classifier.predict(~test_ds,~predictions_ls);
~test_ls.dump({
	arg train_ls_dict;
	~predictions_ls.dump({
		arg pred_ls_dict;
		var n_wrong = 0;
		train_ls_dict["data"].keysValuesDo{
			arg id, expect;
			var pred = pred_ls_dict["data"][id][0][12..];
			expect = expect[0][12..];
			"id: %\nexpected : %\npredicted: %\n".format(id,expect,pred).postln;
			if(expect != pred){n_wrong = n_wrong + 1};
		};
		"number wrong: %".format(n_wrong).postln;
	});
});
)

::
strong::Predict a single point in a buffer::
code::

// analyse a random part of the bells and make a prediction
(
~features = Buffer(s);
~flatbuf = Buffer(s);
~pred_location = rrand(0,~bells.numFrames-1024);
FluidBufMFCC.processBlocking(s,~bells,~pred_location,1024,features:~features,startCoeff:1);
FluidBufFlatten.processBlocking(s,~features,1,1,destination:~flatbuf); // ~features has 3 frames, pull out the middle frame
~classifier.predictPoint(~flatbuf,{
	arg pred;
	"prediction at location: %".format(~pred_location).postln;
	pred.postln;
	"".postln;
});
)

::
strong::Server Side Queries::
This is the equivalent of predictPoint, but entirely on the server
code::

// Play the audio and make a prediction on the server
// the integer reported as the predicted class corresponds to the order (zero-counting) in which the
// labels were introduced to the training labelset. because we processed the bells first, the 0s here
// indicate the prediction of the bells, while the 1s indicate piano.
(
{
	var sig = PlayBuf.ar(1,[~bells,~piano],BufRateScale.ir([~bells,~piano]),loop:1);
	var src = SelectX.ar(ToggleFF.kr(Dust.kr(2)).lag(0.03),sig);
	var mfccs = FluidMFCC.kr(src,startCoeff:1);
	var predict_trig = Impulse.kr(10);
	var mfccbuf = LocalBuf(13);
	var predbuf = LocalBuf(1);
	FluidKrToBuf.kr(mfccs,mfccbuf);
	~classifier.kr(predict_trig,mfccbuf,predbuf);
	FluidBufToKr.kr(predbuf).poll(label:"prediction");
	src.dup;
}.play;
)
::
