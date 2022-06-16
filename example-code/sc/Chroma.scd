
code::

~src = Buffer.readChannel(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"),channels:[0]);

(
~synth = {
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var chroma = FluidChroma.kr(sig,normalize:1); // normalize = 1 makes the output invariant to the signal loudness
	var sines;
	chroma = FluidStats.kr(chroma,40)[0]; // index 0 to get just the means
	SendReply.kr(Impulse.kr(30),"/chroma",chroma);
	sines = SinOsc.ar((69..80).midicps,0,chroma * -5.dbamp);
	sines = Splay.ar(sines);
	sig.dup + sines;
}.play;

//create a monitoring window for the values

~win = Window("Chroma Monitor", Rect(10, 10, 620, 320)).front;
~ms = MultiSliderView(~win,Rect(10, 10, 600, 300)).elasticMode_(1).isFilled_(1);

OSCdef(\chroma,{
	arg msg;
	defer{
		~ms.value_(msg[3..]);
	};
},"/chroma");
)

::
strong::More than 12 pitch classes::
code::

// dividing the octave (and therefore chroma into 19 equal divisions of the octave:

~src = Buffer.readChannel(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"),channels:[0]);

(
~synth = {
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var chroma = FluidChroma.kr(sig,normalize:1,numChroma:19); // normalize = 1 makes the output invariant to the signal loudness
	var freqs, sines;
	chroma = FluidStats.kr(chroma,40)[0]; // index 0 to get just the means
	SendReply.kr(Impulse.kr(30),"/chroma",chroma);
	freqs = chroma.numChannels.collect{arg i; 440 * 2.pow(i/chroma.numChannels)};
	sines = SinOsc.ar(freqs,0,chroma * -5.dbamp);
	sines = Splay.ar(sines);
	sig.dup + sines;
}.play;

//create a monitoring window for the values

~win = Window("Chroma Monitor", Rect(10, 10, 620, 320)).front;
~ms = MultiSliderView(~win,Rect(10, 10, 600, 300)).elasticMode_(1).isFilled_(1);

OSCdef(\chroma,{
	arg msg;
	defer{
		~ms.value_(msg[3..]);
	};
},"/chroma");
)

::