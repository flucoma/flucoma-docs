
code::

// a window to watch the MFCC analyses in real-time
(
~win = Window("MFCCs Monitor",Rect(0,0,800,400)).front;
~ms = MultiSliderView(~win,Rect(0,0,~win.bounds.width,~win.bounds.height)).elasticMode_(1).isFilled_(1);
~ms.reference_(Array.fill(13,{0.5})); //make a center line to show 0
)

//play a simple sound to observe the values
(
~synth = {
	arg type = 0;
	var source = Select.ar(type,[SinOsc.ar(220),Saw.ar(220),Pulse.ar(220)]) * LFTri.kr(0.1).exprange(0.01,0.1);
	var mfccs = FluidMFCC.kr(source,numCoeffs:13,startCoeff:0,maxNumCoeffs:13);
	SendReply.kr(Impulse.kr(30),"/mfccs",mfccs);
	source.dup;
}.play;

~mfccRange = 40;
OSCdef(\mfccs,{
	arg msg;
	{~ms.value_(msg[3..].linlin(~mfccRange.neg,~mfccRange,0,1))}.defer;
},"/mfccs");
)

// change the wave types, observe that, apart from the 0th coefficient, different loudness does not change the values
~synth.set(\type, 1) // sawtooth wave
~synth.set(\type, 2) // pulse wave
~synth.set(\type, 0) // sine wave

~synth.free;

// load a more complex souond
~tbone = Buffer.read(s,FluidFilesPath("Olencki-TenTromboneLongTones-M.wav"));

// notice now that all these trombone sounds look relatively similar because they're the same timbre, even when the trombone changes pitches
(
x = {arg bands = 40;
	var source = PlayBuf.ar(1,~tbone,loop:1);
	var mfccs = FluidMFCC.kr(source, numCoeffs: 13, numBands: bands, maxNumCoeffs: 13);
	SendReply.kr(Impulse.kr(30),"/mfccs",mfccs);
	source.dup;
}.play;

~mfccRange = 70;
OSCdef(\mfccs,{
	arg msg;
	{~ms.value_(msg[3..].linlin(~mfccRange.neg,~mfccRange,0,1))}.defer;
},"/mfccs");
)

// compare with the timbres of oboe multiphonics
~oboe = Buffer.read(s,FluidFilesPath("Harker-DS-TenOboeMultiphonics-M.wav"));

(
x = {
	arg bands = 40;
	var source = PlayBuf.ar(1,~oboe,loop:1);
	var mfccs = FluidMFCC.kr(source, numCoeffs: 13, numBands: bands, maxNumCoeffs: 13);
	SendReply.kr(Impulse.kr(30),"/mfccs",mfccs);
	source.dup;
}.play;

~mfccRange = 70;
OSCdef(\mfccs,{
	arg msg;
	{~ms.value_(msg[3..].linlin(~mfccRange.neg,~mfccRange,0,1))}.defer;
},"/mfccs");
)

::

STRONG::A musical example::

CODE::

// use mfcc analyses to compare two timbres

(
~ds = FluidDataSet(s);
~bass = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcBassGuit-Melo-M.wav"),numFrames:44100 * 9); // only load the first 9 seconds so they're about the same length
~box = Buffer.read(s,FluidFilesPath("Green-Box639.wav"));
~umap = FluidUMAP(s); // algorithm for dimensionality reduction
~norm = FluidNormalize(s);

// a function that will play the buffer and save MFCCs to a FluidDataSet
~analyse = {
	arg buf, name;
	{
		var sig = PlayBuf.ar(1,buf,BufRateScale.ir(buf),doneAction:2);
		var mfccs = FluidMFCC.kr(sig,startCoeff:1);
		var mfccbuf = LocalBuf(13);
		var trig = Impulse.kr(5);
		FluidKrToBuf.kr(mfccs,mfccbuf);
		FluidDataSetWr.kr(~ds,name,PulseCount.kr(trig),mfccbuf,trig); // write a data point 5 times per second
		sig.dup;
	}.play;
};
)

// do the analysis with the bass guitar
~analyse.(~bass,"bass");

// do the analysis with the box
~analyse.(~box,"box");

// check it out
~ds.print;

(
~umap.fitTransform(~ds,~ds);
~norm.fitTransform(~ds,~ds);
~ds.dump({
	arg dict;
	~plotter = FluidPlotter(bounds:Rect(0,0,800,800),dict:dict);
});
)
::
