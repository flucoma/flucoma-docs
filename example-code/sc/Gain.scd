	Summing with the inverse (gain of -1) gives us CPU-expensive silence.
CODE::
{ var source = PinkNoise.ar(0.1); source + FluidGain.ar(source,-1); }.play
::
Varying the gain at audio rate.
CODE::
{ FluidGain.ar(PinkNoise.ar(0.1), gain:LFTri.ar(1)) }.play
::
Varying the gain at control rate, in beautiful stereo.
CODE::
{ FluidGain.ar(SinOsc.ar([222,333],mul:0.1), gain:LFTri.kr([0.5,0.7])) }.play
::
