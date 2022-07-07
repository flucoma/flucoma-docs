STRONG::Use the magnitudes of the melbands analysis to drive a bank of sine oscillators to "resynthesize" the drum loop::
code::
//load a source
~drums = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
x = {
	arg mix = 0.5;
	var source = PlayBuf.ar(1,~drums,BufRateScale.ir(~drums),loop:1);
	var numBands = 40;
	var windowSize = 1024;
	var hopSize = windowSize / 2;
	var melBands = FluidMelBands.kr(
		source,
		numBands,
		maxNumBands:numBands,
		windowSize:windowSize,
		hopSize:hopSize
	);
	var lowMel =  1127.010498 * ((20/700) + 1).log; // convert from hz to mels
	var highMel = 1127.010498 * ((20000/700) + 1).log; // convert from hz to mels
	var rangeMel = highMel - lowMel;
	var stepMel = rangeMel / (numBands+1);
	var freqMel = Array.fill(numBands,{arg i; (stepMel * (i+1)) + lowMel});
	var freqHz = ((freqMel/ 1127.01048).exp - 1) * 700; // convert from mel to hz
	var sines = SinOsc.ar(freqHz,0,melBands.lag(hopSize*SampleDur.ir)).sum;
	var sig = [
		DelayN.ar(source,delaytime:windowSize*SampleDur.ir), // compensate for latency
		sines
	];
	sig = sig * [1-mix,mix];
	sig;
}.play;
)

x.set(\mix,1);

::
STRONG::Use the mouse to select a different band of analysis::
code::
~drums = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
x = {
	arg mix = 0.5;
	var source = PlayBuf.ar(1,~drums,BufRateScale.ir(~drums),loop:1);
	var numBands = 40;
	var windowSize = 1024;
	var hopSize = windowSize / 2;
	var melBands = FluidMelBands.kr(
		source,
		numBands,
		minFreq:MouseX.kr.exprange(20,600),
		maxFreq:MouseY.kr.exprange(650,20000),
		maxNumBands:numBands,
		windowSize:windowSize,
		hopSize:hopSize
	);
	var lowMel =  1127.010498 * ((20/700) + 1).log; // convert from hz to mels
	var highMel = 1127.010498 * ((20000/700) + 1).log; // convert from hz to mels
	var rangeMel = highMel - lowMel;
	var stepMel = rangeMel / (numBands+1);
	var freqMel = Array.fill(numBands,{arg i; (stepMel * (i+1)) + lowMel});
	var freqHz = ((freqMel/ 1127.01048).exp - 1) * 700; // convert from mel to hz
	var sines = SinOsc.ar(freqHz,0,melBands.lag(hopSize*SampleDur.ir)).sum;
	var sig = [
		DelayN.ar(source,delaytime:windowSize*SampleDur.ir), // compensate for latency
		sines
	];
	sig = sig * [1-mix,mix];
	sig;
}.play;
)

x.set(\mix,1);
::
STRONG::Display a chart to see the MelBands::
code::

//create a monitoring window for the values
(
~win = Window("Mel Bands Monitor", Rect(10, 10, 620, 320)).front;
~ms = MultiSliderView(~win,
	Rect(0,0,~win.bounds.width,~win.bounds.height)
).elasticMode_(1).isFilled_(1);
)

//play a simple sound to observe the values
(
OSCdef(\melBands,{
	arg msg;
	var melBands, numBands = msg[3];
	melBands = msg[4..(4+(numBands-1)).asInteger];
	defer{~ms.value_(melBands)};
},"/melBands");

x = {
	arg numBands = 40;
	var source = SinOsc.ar(LFTri.kr(0.1).exprange(80,800),0,0.1);
	var melBands = FluidMelBands.kr(source,numBands:numBands,maxNumBands:40);
	SendReply.kr(Impulse.kr(30),"/melBands",[numBands] ++ melBands);
	source.dup;
}.play;
)

// free this source
x.free

// load a more exciting one
c = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));

// analyse with parameters to be changed
(
OSCdef(\melBands,{
	arg msg;
	var melBands, numBands = msg[3];
	melBands = msg[4..(4+(numBands-1)).asInteger];
	defer{~ms.value_(melBands)};
},"/melBands");

x = {
	arg numBands = 40, minFreq = 20, maxFreq = 20000;
	var source = PlayBuf.ar(1,c,loop:1);
	var melBands = FluidMelBands.kr(source,numBands,minFreq,maxFreq,maxNumBands:40);
	// SendReply.kr(Impulse.kr(30),"/melBands",[numBands] ++ melBands);
	source.dup;
}.play;
)

// observe the number of bands
x.set(\numBands,10);

// back to the full range
x.set(\numBands,40);

// focus all the bands on a mid range
x.set(\minFreq,320, \maxFreq, 800);

// focusing on the low end shows the fft resolution issue. One could restart the analysis with a larger fft to show more precision
x.set(\minFreq,20, \maxFreq, 160);

// back to full range
x.set(\minFreq,20, \maxFreq, 20000);

// free everything
x.free; b.free; c.free; r.stop;
::