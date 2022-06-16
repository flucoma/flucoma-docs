
code::
(
~srcA = Buffer.readChannel(s,FluidFilesPath("Tremblay-CEL-GlitchyMusicBoxMelo.wav"),channels:[0]);
~srcB = Buffer.readChannel(s,FluidFilesPath("Nicol-LoopE-M.wav"),channels:[0]);
)

// fft settings have a large impact on the results. play around with them to hear how.
// and/or see the (real time) FluidAudioTransport example code
(
~result = Buffer(s);
FluidBufAudioTransport.processBlocking(s,
	sourceA:~srcA,
	sourceB:~srcB,
	destination:~result,
	interpolation:0.5,
	windowSize:1024, // this is the default
	hopSize:512, // this is the default
	fftSize:1024, // this is the default
	action:{"done".postln;}
);
)

// the output will be the same length as the shorter source buffer
~result.play;

::
