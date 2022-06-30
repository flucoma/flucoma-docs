code::

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
~synth = {
	var src = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var loudness = FluidLoudness.kr(src);
	var noise = PinkNoise.ar(loudness[0].dbamp);

	loudness[0].poll(label:"Loudness:");
	loudness[1].poll(label:"TruePeak:");
	0.poll(label:"---------------------");

	src = DelayN.ar(src,0.1,1024*SampleDur.ir); // delay to compensate for latency
	[src * -6.dbamp,noise];
}.play;
)

::
strong::EBU Standards::
The EBU standard specifies that the window should be 400ms long, and update every 100ms, for instantaneous loudness. Here we set the windowSize and hopSize appropriately using SampleRate.ir. Various test signals are loaded.
code::

(
~synth = {
	arg freq=220, type = 1, noise = 0;
	var source = PinkNoise.ar(noise) + Select.ar(type,[
		DC.ar(),
		SinOsc.ar(freq,mul:0.1),
		VarSaw.ar(freq,mul:0.1),
		Saw.ar(freq,0.1),
		Pulse.ar(freq,mul:0.1)
	]);
	var loudness = FluidLoudness.kr(source,windowSize:SampleRate.ir*0.4,hopSize:SampleRate.ir*0.1);

	loudness[0].poll(label:"Loudness:");
	loudness[1].poll(label:"TruePeak:");
	0.poll(label:"---------------------");

	source.dup;
}.play;
)

// change the various frequencies to see the impact of the filter for the loudness. The TruePeak is steady.
~synth.set(\freq, 440)
~synth.set(\freq, 110)
~synth.set(\freq, 55)
~synth.set(\freq, 3000)
~synth.set(\freq, 9000)

// adding harmonics, by changing to triangle (2), saw (3) or square (4) shows that spectral algo are more resilient when signal are richer
~synth.set(\type, 2)
~synth.set(\type, 3)
~synth.set(\type, 4)

// adding noise shows its impact on loudness
~synth.set(\noise, 0.25)

// and removing the oscilator
~synth.set(\type, 0)

// and measuring silence
~synth.set(\noise, 0)
::
