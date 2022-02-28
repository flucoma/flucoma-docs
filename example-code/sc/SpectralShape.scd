

code::
//create a monitoring bus for the descriptors
b = Bus.new(\control,0,7);

//create a monitoring window for the values

(
w = Window("spectral Shape Monitor", Rect(10, 10, 220, 190)).front;

c = Array.fill(7, {arg i; StaticText(w, Rect(10, i * 25 + 10, 135, 20)).background_(Color.grey(0.7)).align_(\right)});
c[0].string = ("Centroid: ");
c[1].string = ("Spread: ");
c[2].string = ("Skewness: ");
c[3].string = ("Kurtosis: ");
c[4].string = ("Rolloff: ");
c[5].string = ("Flatness: ");
c[6].string = ("Crest: ");

a = Array.fill(7, {arg i;
	StaticText(w, Rect(150, i * 25 + 10, 60, 20)).background_(Color.grey(0.7)).align_(\center);
});
)

//run the window updating routine.
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

		0.01.wait;
	}.loop

}.play
)

//play a simple sound to observe the values
(
	{
		var source;
		source = BPF.ar(WhiteNoise.ar(), 330, 55/330);
		Out.kr(b,FluidSpectralShape.kr(source));
		source.dup;
	}.play;
)
::

STRONG::A commented tutorial on how each descriptor behaves with test signals: ::

CODE::
// as above, create a monitoring bus for the descriptors
b = Bus.new(\control,0,7);

//again, create a monitoring window for the values
(
w = Window("Spectral Shape Monitor", Rect(10, 10, 220, 190)).front;

c = Array.fill(7, {arg i; StaticText(w, Rect(10, i * 25 + 10, 135, 20)).background_(Color.grey(0.7)).align_(\right)});
c[0].string = ("Centroid: ");
c[1].string = ("Spread: ");
c[2].string = ("Skewness: ");
c[3].string = ("Kurtosis: ");
c[4].string = ("Rolloff: ");
c[5].string = ("Flatness: ");
c[6].string = ("Crest: ");

a = Array.fill(7, {arg i;
	StaticText(w, Rect(150, i * 25 + 10, 60, 20)).background_(Color.grey(0.7)).align_(\center);
});
)

// this time, update a little more slowly.
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

		0.2.wait;
	}.loop

}.play
)

// first, a sine wave
(
x = {
	arg freq=220;
	var source;
	source = SinOsc.ar(freq,mul:0.1);
	Out.kr(b, VarLag.kr(FluidSpectralShape.kr(source),1024/s.sampleRate));
	source.dup;
}.play;
)

// at 220, the centroid is on the frequency, the spread is narrow, but as wide as the FFT Hann window ripples, the skewness is high as we are low and therefore far left of the middle bin (aka half-Nyquist), the Kurtosis is incredibly high as we have a very peaky spectrum. The rolloff is slightly higher than the frequency, taking into account the FFT windowing ripples, the flatness is incredibly low, as we have one peak and not much else, and the crest is quite high, because most of the energy is in a few peaky bins.

x.set(\freq, 440)

// at 440, the skewness has changed (we are nearer the middle of the spectrogram) and the Kurtosis too, although it is still so high it is quite in the same order of magnitude. The rest is stable, as expected.

x.set(\freq, 11000)

// at 11kHz, kurtosis is still in the thousand, but skewness is almost null, as expected.

x.free

// second, broadband noise
(
x = {
	arg type = 0;
	var source;
	source = Select.ar(type,[WhiteNoise.ar(0.1),PinkNoise.ar(0.1)]);
	Out.kr(b, VarLag.kr(FluidSpectralShape.kr(source),1024/s.sampleRate));
	source.dup;
}.play;
)

// white noise has a linear repartition of energy, so we would expect a centroid in the middle bin (aka half-Nyquist) with a spread covering the full range (+/- a quarter-Nyquist), with a skewness almost null since we are centered, and a very low Kurtosis since we are flat. The rolloff should be almost at Nyquist, the flatness as high as it gets, and the crest quite low.

x.set(\type, 1)

// pink noise has a drop of 3dB per octave across the spectrum, so we would, by comparison, expect a lower centroid, a slighly higher skewness and kurtosis, a lower rolloff, a slighly lower flatness and a higher crest for the larger low-end energy.

x.free

// third, bands of noise
(
x = {
	arg type = 0;
	var source, chain;
	chain = FFT(LocalBuf(1024), WhiteNoise.ar(0.5));
	chain = chain.pvcollect(1024, {arg mag,phase;[mag,phase]},5,11,1);
	source = Select.ar(type,[
		BPF.ar(BPF.ar(WhiteNoise.ar(0.5),330,0.666),330,0.666),
		IFFT(chain)]);
	Out.kr(b, VarLag.kr(FluidSpectralShape.kr(source),1024/s.sampleRate));
	source.dup;
}.play;
)

// a second-order bandpass filter on whitenoise, centred on 330Hz with one octave bandwidth, gives us a centroid quite high. This is due to the exponential behaviour of the filter, with a gentle slope. Observe the spectral analyser:

s.freqscope

// at first it seems quite centred, but then flip the argument FrqScl to lin(ear) and observe how high the spectrum goes. If we set it to a brickwall spectral filter tuned on the same frequencies:

x.set(\type, 1)

// we have a much narrower register, and our centroid and spread, as well as the kurtosis and flatness, agrees with this reading.

x.free

//fourth, equally spaced sines
(
x = {
	arg freq = 220;
	var source;
	source = 	Mix.fill(7, {arg ind; SinOsc.ar(freq + (ind * (220 / 6)), 0, 0.02)});
	Out.kr(b,FluidSpectralShape.kr(source));
	source.dup;
}.play;
)

// this example shows a similar result to the brickwall spectral bandpass above. If we move the central frequency nearer the half-Nyquist:

x.set(\freq, 8800)

// we can observe that the linear spread is kept the same, since there is the same linear distance in Hz between our frequencies. Skewness is a good indication here of where we are in the spectrum with the shape.
::


STRONG::A few notes on the impact of the scale options::

CODE::
// The computation of the centroids and other moments can also be done considering a logarithmic pitch scale, and/or the power of the magnitudes. This yields values that are more in line with the expectation of the users of equalisers for instance, where the shape is often drawn and described in logairhmic terms, i.e. dB per octave.

// For instance, compare the values of the centroid and the spread in both scales:
(
{
	var source = BPF.ar(PinkNoise.ar(0.1),MouseX.kr().exprange(300,3000).poll(1,label: "filter frequency"), 0.5);
	FluidSpectralShape.kr(source, minFreq: 20, maxFreq: 20000, unit: 0, power: 0)[0].lag.poll(1,"linear centroid");
	FluidSpectralShape.kr(source, minFreq: 20, maxFreq: 20000, unit: 1, power: 1)[0].lag.midicps.poll(1,"exponential centroid");//convert from midi to Hz
	source.dup
}.play
)

// The lower one gets in frequency, the more the linear spectral bias shows. The same applies to the spread:

(
{
	var source = BPF.ar(PinkNoise.ar(0.1),440, MouseX.kr().exprange(0.1,4).poll(1,label: "filter RQ"));
	FluidSpectralShape.kr(source, minFreq: 20, maxFreq: 20000, unit: 0, power: 0)[1].lag.poll(1,"linear spread");
	FluidSpectralShape.kr(source, minFreq: 20, maxFreq: 20000, unit: 1, power: 1)[1].lag.poll(1,"exponential spread");
	source.dup
}.play
)

// The logarythmic unit is in semitones. To convert, either divide by 12 to get the octave of one standard deviation, or divide by 6 to get the width of the filter in octaves. One clear observation is that the width is now in a range that scales with what we hear, growing fourfold as the filter goes from resonating to more broadband.

// An example of productive mapping between filters parameters and logarithmic centroid values allows to make a simple automatic subtractive noise resynthesis

// load a beat
b = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

//logcentroid version
(
{
	var source = PlayBuf.ar(1,b,loop: 1);
	var loudness, centroid, spread;

	#centroid,spread = Lag.kr(FluidSpectralShape.kr(source, minFreq: 20, maxFreq: 20000, unit: 1, power: 1, hopSize: 128),128/SampleRate.ir);
	loudness =  Lag.kr(FluidLoudness.kr(source,hopSize: 128),128/SampleRate.ir);
	[
		DelayN.ar(source,delaytime: 1024/SampleRate.ir),
		BBandPass.ar(WhiteNoise.ar(),
			centroid.midicps,
			(spread/6),
			loudness[0].dbamp * 2
		)
		]
}.scope;
)

//lincentroid version for comparison
(
{
	var source = PlayBuf.ar(1,b,loop: 1);
	var loudness, centroid, spread;

	#centroid,spread = Lag.kr(FluidSpectralShape.kr(source, minFreq: 20, maxFreq: 20000, unit: 0, power: 0, hopSize: 128),128/SampleRate.ir);
	loudness =  Lag.kr(FluidLoudness.kr(source,hopSize: 128),128/SampleRate.ir);
	[
		DelayN.ar(source,delaytime: 1024/SampleRate.ir),
		Sanitize.ar(BBandPass.ar(WhiteNoise.ar(),
			centroid,
			(spread * 2/centroid).max(0.001),
			loudness[0].dbamp * 2
	))
		]
}.scope;
)
::
