
CODE::
// load some audio to play
b = Buffer.read(s,File.realpath(FluidSines.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-SynthTwoVoices-M.wav");

// run with large parameters - left is sinusoidal model, right is residual
{FluidSines.ar(PlayBuf.ar(1,b,loop:1),detectionThreshold: -40, minTrackLen: 2, windowSize: 2048, fftSize: 8192)}.play

// interactive parameters with a narrower bandwidth
{FluidSines.ar(PlayBuf.ar(1,b,loop:1), 30, MouseX.kr(-140,-10),MouseY.kr(-110,-10),MouseY.kr(-140,-40), 10 , windowSize: 1000, hopSize: 200, fftSize: 4096)}.play

// null test (the process add a latency of (( hopSize * minTrackLen) + windowSize) samples
{var sig = PlayBuf.ar(1,b,loop:1); [FluidSines.ar(sig).sum - DelayN.ar(sig, 1, ((( 512 * 15) + 1024)/ s.sampleRate))]}.play

// as the algorithm resynthesize the sinusoidal peaks, we would expect to get it to work almost perfectly on a sine wave, with these settings that tell the process to tolerate everything as a sinusoid, even short and quiet peaks
{FluidSines.ar(SinOsc.ar(mul: 0.1),detectionThreshold: -144,birthLowThreshold: -144,birthHighThreshold: -144,minTrackLen: 1,trackMagRange: 200,trackFreqRange: 1000,trackProb: 0)}.play;

// we can listen to the artefact in solo, amplifying it by 30dB, to hear the 'lobes' - not bad at all!
{FluidSines.ar(SinOsc.ar(mul: 0.1),detectionThreshold: -144,birthLowThreshold: -144,birthHighThreshold: -144,minTrackLen: 1,trackMagRange: 200,trackFreqRange: 1000,trackProb: 0)[1].dup * Line.ar(0,30,1).dbamp}.play;

// as this is a windowed process, the frequency of the peak is good for that full window, and therefore interesting artefacts appear when the pitch is changing.
{FluidSines.ar(SinOsc.ar(LFTri.kr(0.1).exprange(220,880),mul: 0.1),detectionThreshold: -144,birthLowThreshold: -144,birthHighThreshold: -144,minTrackLen: 1,trackMagRange: 300,trackFreqRange: 1000,trackProb: 0)}.play;

// if we solo and amplify the artefacts, they are much more apparent (and interesting)
{FluidSines.ar(SinOsc.ar(LFTri.kr(0.1).exprange(220,880),mul: 0.1),detectionThreshold: -144,birthLowThreshold: -144,birthHighThreshold: -144,minTrackLen: 1,trackMagRange: 300,trackFreqRange: 1000,trackProb: 0)[1].dup * Line.ar(0,30,1).dbamp}.play;
::
