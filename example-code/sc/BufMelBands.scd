STRONG::Use a buffer of MelBands to drive a bank of oscillators::
code::
(
~bells = Buffer.readChannel(s,FluidFilesPath("Tremblay-CF-ChurchBells.wav"),channels:[0]);
~melBands = Buffer(s);
~numBands = 100;
)

// listen to the original
~bells.play;

// analyse
FluidBufMelBands.processBlocking(s,~bells,features:~melBands,numBands:~numBands,action:{"done".postln});

// playback
(
x = {
	arg rate = 0.1, freqMul = 1, freqAdd = 0;
	var phs = Phasor.kr(0,rate,0,BufFrames.ir(~melBands));
	var melBands = BufRd.kr(~numBands,~melBands,phs,1,4);
	var lowMel =  1127.010498 * ((20/700) + 1).log; // convert from hz to mels
	var highMel = 1127.010498 * ((20000/700) + 1).log; // convert from hz to mels
	var rangeMel = highMel - lowMel;
	var stepMel = rangeMel / (~numBands+1);
	var freqMel = Array.fill(~numBands,{arg i; (stepMel * (i+1)) + lowMel});
	var freqHz = ((freqMel/ 1127.01048).exp - 1) * 700; // convert from mel to hz
	var sig = SinOsc.ar((freqHz * freqMul) + freqAdd,0,melBands);
	Splay.ar(sig) * 24.dbamp;
}.play;
)

// manipulate the oscillator bank
x.set(\rate,0.3);
x.set(\rate,0.04);
x.set(\freqMul,0.5);
x.set(\freqAdd,-2000);

::
STRONG::Look at the MelBands in FluidWaveform (as "features")::
code::
// create some buffers
(
~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));
~melBands = Buffer.new(s);
)

// run the process with basic parameters
FluidBufMelBands.processBlocking(s,~src,features:~melBands,action:{"done".postln});

// look at the mel bands as feature curves (a bit messy...)
FluidWaveform(~src,featuresBuffer:~melBands,bounds:Rect(0,0,1600,400),stackFeatures:true,normalizeFeaturesIndependently:false);
::
STRONG::Do a higher resolution analysis and plot it as an image in FluidWaveform::
code::
// create some buffers
(
~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));
~melBands = Buffer.new(s);
)

FluidBufMelBands.processBlocking(s,~src,features:~melBands,numBands:400,fftSize:4096,action:{"done".postln});

FluidWaveform(imageBuffer:~melBands,bounds:Rect(0,0,1600,400),imageColorScheme:1,imageColorScaling:1);
::