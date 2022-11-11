
CODE::

// a didactic example: a cluster of sinusoids, sorted by magnitudes
{var source = SinOsc.ar([440,789],mul: [0.05,0.1]).sum; FluidSineFeature.kr(source,numPeaks: 3, order: 1).poll; source.dup}.play

// or in MIDI and dB
{var source = SinOsc.ar([69,79].midicps,mul: [-40,-35].dbamp).sum; FluidSineFeature.kr(source,numPeaks: 3, order: 1, freqUnit: 1, magUnit: 1).poll; source.dup}.play

// a more exciting example: resynthesizing audio input
(
var buf = Buffer.read(s,FluidFilesPath("Harker-DS-TenOboeMultiphonics-M.wav"));

x = {
	arg nbPeaks = 10, t_hold = 1;
	var source = PlayBuf.ar(1, buf, loop: 1);
	var analysis = Latch.kr(FluidSineFeature.kr(source,numPeaks: nbPeaks, maxNumPeaks: 50),t_hold);
	var resynth = SinOsc.ar(analysis[Array.iota(50)], mul: analysis[Array.iota(50) + 50]).sum;
	[source, resynth];
}.play
)

// play with the number of peaks to track
x.set(\nbPeaks, 5)
x.set(\nbPeaks, 1)
x.set(\nbPeaks, 50)

// trigger the holder to hear the reconstruction on the right hand side
x.set(\t_hold, 1)

// or make it automatic
r = Routine{x.set(\t_hold, 1);0.01.wait;}.loop.play
r.stop
::
