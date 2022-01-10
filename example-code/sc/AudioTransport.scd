
code::
//didactic - the mouse X axis interpolates between the two sinewaves
{FluidAudioTransport.ar(SinOsc.ar(220,mul: 0.1),SinOsc.ar(440,mul: 0.02),MouseX.kr())}.play;

//notice how the interpolation quantizes to the FFT bins. Like most spectral processes, it benefits from oversampling the fft... at the cost of  CPU power, obviously.
{FluidAudioTransport.ar(SinOsc.ar(220,mul: 0.1),SinOsc.ar(440,mul: 0.02),MouseX.kr(),fftSize: 8192)}.play;

// when the signal is steady, larger hopSize can be accommodated to save back on the CPU
{FluidAudioTransport.ar(SinOsc.ar(220,mul: 0.1),SinOsc.ar(440,mul: 0.02),MouseX.kr(),windowSize: 8192)}.play; // here we get a default hop of half the window so 8 times less than above.

//if you CPU can cope, try this setting, almost smooth, but attacks would smear (the Y axis mixes some in to hear the effect)
{var attacks = Impulse.ar(1,mul: MouseY.kr(-40,10).dbamp); FluidAudioTransport.ar(SinOsc.ar(220,mul: 0.1,add: attacks),SinOsc.ar(440,mul: 0.02,add: attacks),MouseX.kr(),windowSize: 16000)}.play;

//richer with complex spectra
//load 2 files
(
b = Buffer.read(s,File.realpath(FluidAudioTransport.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-CEL-GlitchyMusicBoxMelo.wav");
c = Buffer.read(s,File.realpath(FluidAudioTransport.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-CF-ChurchBells.wav");
)
//listen to them
b.play
c.play
//stereo cross!
{FluidAudioTransport.ar(PlayBuf.ar(2,b,loop: 1),PlayBuf.ar(2,c,loop: 1),MouseX.kr())}.play;

::