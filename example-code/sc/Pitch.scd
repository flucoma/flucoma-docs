

code::
//create a monitoring bus for the descriptors
b = Bus.new(\control,0,4);

//create a monitoring window for the values
(
w = Window("Frequency Monitor", Rect(10, 10, 220, 115)).front;

c = Array.fill(4, {arg i; StaticText(w, Rect(10, i * 25 + 10, 135, 20)).background_(Color.grey(0.7)).align_(\right)});
c[0].string = ("FluidPitch: ");
c[1].string = ("confidence: ");
c[2].string = ("SC Pitch: ");
c[3].string = ("Confidence: ");

a = Array.fill(4, {arg i;
	StaticText(w, Rect(150, i * 25 + 10, 60, 20)).background_(Color.grey(0.7)).align_(\center);
});
)

//routine to update the parameters
(
r = Routine {
	{

		b.get({ arg val;
			{
				if(w.isClosed.not) {
					val.do({arg item,index;
						a[index].string = item.round(0.01)})
				}
			}.defer
		});

		0.1.wait;
	}.loop

}.play
)

//test signals, all in one synth
(
x = {
	arg freq=220, type = 0, noise = 0;
			var source = PinkNoise.ar(noise) + Select.ar(type,[SinOsc.ar(freq,mul:0.1), VarSaw.ar(freq,mul:0.1), Saw.ar(freq,0.1), Pulse.ar(freq,mul:0.1), Mix.new(Array.fill(8, {arg i; SinOsc.ar(LFNoise1.kr(0.1.rand,10,220*(i+1)),mul:(i+1).reciprocal * 0.1)}))]);
	Out.kr(b, FluidPitch.kr(source) ++ Pitch.kr(source));
	source.dup;
}.play;
)

// the built-in is slightly better on pure sinewaves
x.set(\freq, 440)

// adding harmonics, by changing to triangle (1), saw (2) or square (3) shows that spectral algo are more resilient when signal are richer
x.set(\type, 1)
x.set(\type, 2)
x.set(\type, 3)

// adding noise shows the comparative sturdiness of the spectral pitch tracker
x.set(\noise, 0.05)

//if latency is no issue, getting a higher windowSize will stabilise the algorithm even more
::

STRONG::a more musical example::
CODE::
// play a noisy synth file
b = Buffer.read(s,File.realpath(FluidPitch.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-ASWINE-ScratchySynth-M.wav");
b.play(true);

//insert a selective reverb - sending only the material with very high pitch confidence
(
f = {var source, rev;
	source = In.ar(0,2);
	rev = FreeVerb.ar(DelayN.ar(source,delaytime:1024/s.sampleRate) * Lag.kr((FluidPitch.kr(source.sum)[1] > 0.98),0.01), 1);
	ReplaceOut.ar(0, rev+ source);
}.play(addAction:\addToTail);
)

// free the effect
f.free

// insert a stereo delay instead (as well) using the same
(
f = {
	var source, todelay, delay1, delay2, delay3, feedback, mod1, mod2, mod3, mod4;
	//read the source
	source = In.ar(0,2);

	// generate modulators that are coprime in frequency
	mod1 = SinOsc.ar(1, 0, 0.001);
	mod2 = SinOsc.ar(((617 * 181) / (461 * 991)), 0, 0.001);
	mod3 = SinOsc.ar(((607 * 193) / (491 * 701)), 0, 0.001);
	mod4 = SinOsc.ar(((613 * 191) / (463 * 601)), 0, 0.001);

	// gate the signal to send to the delays
	todelay = DelayN.ar(source,delaytime:1024/s.sampleRate) * Lag.kr((FluidPitch.kr(source.sum)[1] > 0.98),0.01);

	// delay network
	feedback = LocalIn.ar(3);// take the feedback in for the delays
	delay1 = DelayC.ar(BPF.ar(todelay+feedback[1]+(feedback[2] * 0.3), 987, 6.7,0.35),0.123,0.122+(mod1*mod2));
	delay2 = DelayC.ar(BPF.ar(todelay+feedback[0]+(feedback[2] * 0.3), 1987, 6.7,0.35),0.345,0.344+(mod3*mod4));
	delay3 = DelayC.ar(BPF.ar(todelay+feedback[1], 1456, 6.7,0.35),0.567,0.566+(mod1*mod3),0.6);
	LocalOut.ar([delay1,delay2, delay3]); // write the feedback for the delays

			ReplaceOut.ar(0, source + [delay1+delay3,delay2+delay3]);
}.play(addAction:\addToTail);
)
::
