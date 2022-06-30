
code::

(
~srcA = Buffer.readChannel(s,FluidFilesPath("Tremblay-CEL-GlitchyMusicBoxMelo.wav"),channels:[0]);
~srcB = Buffer.readChannel(s,FluidFilesPath("Nicol-LoopE-M.wav"),channels:[0]);
)

(
{
	var srcA = PlayBuf.ar(1,~srcA,BufRateScale.ir(~srcA),loop:1);
	var srcB = PlayBuf.ar(1,~srcB,BufRateScale.ir(~srcB),loop:1);
	FluidAudioTransport.ar(srcA,srcB,MouseX.kr,1024,64,2048).dup;
}.play
)

::
strong::The impact of FFT Settings::
The larger the FFT size the better it blends the spectral qualities at the expense of smearing attacks. This will have a drastic impact on the characteristic of the interpolation.
code::

(
~srcA = Buffer.readChannel(s,FluidFilesPath("Tremblay-CEL-GlitchyMusicBoxMelo.wav"),channels:[0]);
~srcB = Buffer.readChannel(s,FluidFilesPath("Nicol-LoopE-M.wav"),channels:[0]);
)

(
~synth = {
	arg windowSize = 1024, hopSize = 64, fftSize = 2048;
	var srcA = PlayBuf.ar(1,~srcA,BufRateScale.ir(~srcA),loop:1);
	var srcB = PlayBuf.ar(1,~srcB,BufRateScale.ir(~srcB),loop:1);
	FluidAudioTransport.ar(srcA,srcB,MouseX.kr,windowSize,hopSize,fftSize,16384).dup;
}.play
)

// Try these different FFT settings to see how they affect the results of the audio transport algorithm

~synth.set(\windowSize,256,\hopSize,16,\fftSize,256);
~synth.set(\windowSize,1024,\hopSize,16,\fftSize,1024);
~synth.set(\windowSize,1024,\hopSize,-1,\fftSize,-1);
~synth.set(\windowSize,2048,\hopSize,-1,\fftSize,-1);
~synth.set(\windowSize,4096,\hopSize,-1,\fftSize,-1);
~synth.set(\windowSize,16384,\hopSize,-1,\fftSize,-1);

::
Creative Modulation
code::

(
~srcA = Buffer.readChannel(s,FluidFilesPath("Tremblay-CEL-GlitchyMusicBoxMelo.wav"),channels:[0]);
~srcB = Buffer.readChannel(s,FluidFilesPath("Nicol-LoopE-M.wav"),channels:[0]);
)

(
{
	var srcA = PlayBuf.ar(1,~srcA,BufRateScale.ir(~srcA),loop:1);
	var srcB = PlayBuf.ar(1,~srcB,BufRateScale.ir(~srcB),loop:1);
	var amp = Amplitude.kr(srcB);
	var interp = LFDNoise3.kr(100 * amp).range(0,1).poll;
	var sig = FluidAudioTransport.ar(srcA,srcB,interp,2048).dup;
	sig + (srcB * -20.dbamp);
}.play
)
::