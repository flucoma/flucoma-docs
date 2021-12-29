
Summing with the inverse (gain of -1) with a delay of the latency gives us CPU-expensive silence.
CODE::
{ var source = PinkNoise.ar(0.1); DelayN.ar(source, delaytime:1024/s.sampleRate, mul: -1) + FluidSTFTPass.ar(source, 1024); }.play
::
Larger, oversampled, FFT
CODE::
{ FluidSTFTPass.ar(PinkNoise.ar(0.1), 2048, 128, 8192) }.play
::
Stereo Input Tests.
CODE::
{ FluidSTFTPass.ar([SinOsc.ar(222,mul: 0.1), PinkNoise.ar(Decay.ar(Impulse.ar(0.666,mul: 0.2), 0.5))], fftSize:1024)}.play
::
Stereo Parameter Tests.
CODE::
{ FluidSTFTPass.ar(SinOsc.ar(222,mul: 0.1), [1024,8192],256,8192)}.play
::
Modulating Window Param Tests.
CODE::
{ var source = SinOsc.ar(222,mul: 0.1);  [source, FluidSTFTPass.ar(source,LFNoise0.kr(1).range(10,10000))] }.play
::
Very Short FFT test.
CODE::
{ var source = SinOsc.ar(222,mul: 0.1);  [source, FluidSTFTPass.ar(source,10)] }.play
::
