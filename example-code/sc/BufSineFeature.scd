strong::Plot the BufSineFeature curves one over the other::
code::
~oboe = Buffer.read(s,FluidFilesPath("Harker-DS-TenOboeMultiphonics-M.wav"),numFrames: 311000);

(
~freq = Buffer(s);
~mags = Buffer(s);
FluidBufSineFeature.processBlocking(s,~oboe, frequency: ~freq, magnitude: ~mags, numPeaks: 5);
w = Window("FluidWaveform Test",Rect(0,0,1000,500));
w.view.layout = VLayout(
	FluidWaveform(~oboe,featuresBuffer: ~freq,standalone: false),
	FluidWaveform(~oboe,featuresBuffer: ~mags,standalone: false));
w.front;
)
::

strong::A few didactic examples::
code::

//mono source of 3 sines
b = {SinOsc.ar([440,789,535],mul: [0.01,0.03,0.02]).sum}.asBuffer(1)

//listen
b.play

//make destination buffers
~freq = Buffer(s); ~mags = Buffer(s);

//process
FluidBufSineFeature.process(s,b,frequency: ~freq, magnitude: ~mags, numPeaks: 4, action: {\done.postln})

// retrieve the first 2 frames of 4 peaks
~freq.getn(0, 8, {|x|x.postln})
~mags.getn(0, 8, {|x|x.postln})

// there are only 2 peaks... this is because the distance between 2 peaks has to be clearly segregated in the FFT world. At the default 1024 and the usual SC SR of 44100, this is 43Hz per bin, so 440 and 535 are too near each other... if we reprocess with a higher frame size, we get the right values

FluidBufSineFeature.process(s,b,frequency: ~freq, magnitude: ~mags, numPeaks: 4, windowSize: 2048, action: {\done.postln})

// first 2 frames of 4 peaks
~freq.getn(0, 8, {|x|x.postln})
~mags.getn(0, 8, {|x|x.postln})

//here is another source for fun, stereo this time, and triangle waves
b = {LFTri.ar([300, 500],mul: [-40, -45].dbamp)}.asBuffer(1)

b.play
b.query

// asking for 2 peaks - first and third harmonic of each should pop out
FluidBufSineFeature.process(s, b, frequency: ~freq, magnitude: ~mags, numPeaks: 2, magUnit: 1, action: {\done.postln})

// retrieving - the stereo values are interleaved, 2 for left 2 for right.
~freq.getn(0, 8, {|x|x.postln})
~mags.getn(0, 8, {|x|x.postln})

::


