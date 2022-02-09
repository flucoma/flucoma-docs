Use the pitch and confidence descriptions to control some filtered noise.
code::

// load some audio
~scratchy = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));

// synth to do the analysis and drive the BPF
(
{
	var src = PlayBuf.ar(~scratchy.numChannels,~scratchy,BufRateScale.ir(~scratchy),loop:1);
	var sig, freq, conf, windowSize = 1024;
	var latency = windowSize / SampleRate.ir;
	# freq, conf = FluidPitch.kr(src,windowSize:windowSize);
	freq = freq.lag(0.03);
	sig = BPF.ar(PinkNoise.ar(1),freq.clip(1,20000),0.1,conf);
	[DelayN.ar(src,latency,latency),sig];
}.play;
)
::

Use the confidence descriptor to modulate a send amount to a delay line.

code::
// load some audio
~scratchy = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));

// This synth sends the source sound to the delay only when the pitch confidence is above 0.95.
// This way the scratchy, distorted parts of the sound file are not heard in the delay.
(
{
	var src = PlayBuf.ar(~scratchy.numChannels,~scratchy,BufRateScale.ir(~scratchy),loop:1);
	var sig, freq, conf, windowSize = 1024;
	var latency = windowSize / SampleRate.ir;
	# freq, conf = FluidPitch.kr(src,windowSize:windowSize);
	src = DelayN.ar(src,latency,latency);
	sig = CombC.ar(src * (conf > 0.98).lag(0.01),0.5,0.1,3);
	[src,sig];
}.play;
)

::
Just watch the parameters come out.
code::
~bass = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcBassGuit-Melo-M.wav"));

(
{
	var src = PlayBuf.ar(~bass.numChannels,~bass,BufRateScale.ir(~bass),loop:1);
	var freq, conf, windowSize = 4096; //
	var latency = windowSize / SampleRate.ir;
	# freq, conf = FluidPitch.kr(src,windowSize:windowSize);
	SendReply.kr(Impulse.kr(30),"/fluidpitch_help",[freq,conf]);
	DelayN.ar(src,latency,latency);
}.play;

o = OSCFunc({
	arg msg;
	"freq: %\tnote: %\tconf: %".format(msg[3].round(0.01).asString.padLeft(8),msg[3].cpsname,msg[4].round(0.01).asString.padRight(4)).postln;
},"/fluidpitch_help");
)

::
Just watch the parameters come out on a strong::stereo:: signal.
code::
// When a stereo signal is analyzed by FluidPitch.kr it will output a 2D array as a KR stream.
// See the .poll calls in the synth to see how the freq and conf for each channel are organized.
~piano_stereo = Buffer.read(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"));

(
{
	var src = PlayBuf.ar(~piano_stereo.numChannels,~piano_stereo,BufRateScale.ir(~piano_stereo),loop:1);
	var pitch_output, windowSize = 1024; //
	var latency = windowSize / SampleRate.ir;
	pitch_output = FluidPitch.kr(src,windowSize:windowSize);
	pitch_output[0][0].poll(label:"L freq:");
	pitch_output[0][1].poll(label:"L conf:");
	pitch_output[1][0].poll(label:"R freq:");
	pitch_output[1][1].poll(label:"R conf:");
	DelayN.ar(src,latency,latency);
}.play;
)

::
Comparison with Pitch.kr
code::
(
//a monitoring bus for the descriptors
~bus = Bus.control(s,4);

//a monitoring window for the values
~win = Window("Frequency Monitor", Rect(400, 400, 220, 115)).front;

~labels = Array.fill(4,{
	arg i;
	StaticText(~win, Rect(10, i * 25 + 10, 135, 20)).background_(Color.grey(0.7)).align_(\right)
});
~labels[0].string = ("FluidPitch: ");
~labels[1].string = ("confidence: ");
~labels[2].string = ("SC Pitch: ");
~labels[3].string = ("Confidence: ");

~analyses_text = Array.fill(4, {
	arg i;
	StaticText(~win, Rect(150, i * 25 + 10, 60, 20)).background_(Color.grey(0.7)).align_(\center);
});

//routine to update the parameters
~update_loop = Routine{
	{
		~bus.get({ arg val;
			{
				if(~win.isClosed.not) {
					val.do({arg item,index;
						~analyses_text[index].string = item.round(0.01)})
				}
			}.defer
		});
		0.1.wait;
	}.loop
}.play;

//test signals, all in one synth
~synth = {
	arg freq=220, type = 0, noise = 0;
	var noise_sig = PinkNoise.ar(noise);
	var tone = Select.ar(type,[
		SinOsc.ar(freq,mul:0.1),
		LFTri.ar(freq,mul:0.1),
		Saw.ar(freq,0.1),
		Pulse.ar(freq,mul:0.1),
		Mix.new(Array.fill(8, {arg i; SinOsc.ar(LFNoise1.kr(0.1.rand,10,220*(i+1)),mul:(i+1).reciprocal * 0.1)}))
	]);
	var source = tone + noise_sig;
	Out.kr(~bus, FluidPitch.kr(source) ++ Pitch.kr(source));
	source.dup;
}.play;
)

// Pitch.kr is slightly better on pure sine waves
~synth.set(\freq, 440)

// adding harmonics, by changing to triangle (1), saw (2) or square (3) shows that these algorithms are more resilient when the signal is richer
~synth.set(\type,1) // tri
~synth.set(\type,2) // saw
~synth.set(\type,3) // square
~synth.set(\type,4) // band of sine waves

// adding noise shows that the algorithm is robust to some noise
~synth.set(\noise, 0.2)
::
