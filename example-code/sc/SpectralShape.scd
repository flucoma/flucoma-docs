code::

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
~synth = {
	arg power = 1;
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var spec = FluidSpectralShape.kr(sig,[\centroid,\spread],unit:1,power:power);
	var noise = WhiteNoise.ar(1);
	var q = pow(2,spec[1]/6);
	q = pow(q,0.5) / (q-1);

	spec[0].poll(label:"centroid midi");
	spec[1].poll(label:"spread midi");
	spec[0].midicps.poll(label:"centroid hz");
	q.poll(label:"q");
	0.poll(label:"---------------------------");

	noise = BPF.ar(noise,spec[0].midicps.lag(0.1),1);
	noise = noise * FluidLoudness.kr(sig,[\loudness]).dbamp * 10.dbamp;
	Limiter.ar([sig,noise]);
}.play;
)

~synth.set(\power,1);

::
strong::logarithmic scale::
The computation of the spectral centroid can also be done considering a logarithmic pitch scale and the power of the magnitudes. This yields values that are generally considered to be more in line with perception, for instance where the shape is often drawn and described in logarithmic terms, i.e., dB per octave.

Compare the values of the centroid and the spread in both scales. The lower the frequency, the more the linear spectral bias shows. The same applies to the spread. The logarithmic unit is in semitones. To convert, etiher divide by 12 to get the octave of one standard deviation, or divide by 6 to get the width of the filter in octaves. One clear observation is that the width is now in a range that scales with what we hear, growing fourfold as the filter goes from resonanting to more broadband.
code::

(
{
	var freq = MouseX.kr(20,20000,1);
	var q = MouseY.kr(1,100);
	var noise = BPF.ar(PinkNoise.ar,freq,q.reciprocal);
	var lin = FluidStats.kr(FluidSpectralShape.kr(noise,[\centroid,\spread]),40)[0];
	var log = FluidStats.kr(FluidSpectralShape.kr(noise,[\centroid,\spread],unit:1,power:1),40)[0];

	freq.poll(label:"filter frequency ");
	q.poll(label:"filter q         ");
	lin[0].poll(label:"lin centroid     ");
	lin[1].poll(label:"lin spread       ");
	log[0].midicps.poll(label:"log centroid     ");
	log[1].poll(label:"log spread       ");
	0.poll(label:"-------------------------");

	noise.dup;
}.play;
)

::