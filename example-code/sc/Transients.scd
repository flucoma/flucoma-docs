
CODE::
//load some buffer
b = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));

// basic parameters
{FluidTransients.ar(PlayBuf.ar(1, b, loop:1))}.play

// tweaked parameters
{FluidTransients.ar(PlayBuf.ar(1, b, loop:1), 80, threshFwd:MouseX.kr(0,5), threshBack:MouseY.kr(0,2))}.play

// null test (the process add a latency of (blockSize + padding - order) samples
{var sig = PlayBuf.ar(1, b, loop:1); [FluidTransients.ar(sig).sum - DelayN.ar(sig, 1, ((256 + 128 - 20)/ s.sampleRate))]}.play
::
