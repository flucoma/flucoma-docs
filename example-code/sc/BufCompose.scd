
code::
// load some buffers
(
b = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));
c = Buffer.read(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"));
d = Buffer.new(s);
)

// with basic params (basic summing of each full buffer in all dimensions)
(
Routine{
    FluidBufCompose.process(s, source: b,  destination: d);
    FluidBufCompose.process(s, source: c,  destination: d, destGain: 1.0);
	s.sync;
    d.query;
    d.play;
}.play;
)
//constructing a mono buffer, with a quiet punch from the synth, with a choked piano resonance from the left channel
(
Routine{
    d.free; d = Buffer.new(s);
    FluidBufCompose.process(s, source: b, numFrames: 9000, gain: 0.5, destination: d);
    FluidBufCompose.process(s, source: c, startFrame:30000, numFrames:44100, numChans:1, gain:0.9, destination: d, destGain: 1.0).wait;
    d.query;
    d.play;
}.play
)
//constructing a stereo buffer, with the end of the mono synth in both channels, with a piano resonance in swapped stereo
(
Routine{
    d.free; d = Buffer.new(s);
    FluidBufCompose.process(s, source: b, startFrame: 441000, numChans: 2, gain: 0.6, destination: d);
    FluidBufCompose.process(s, source: c, numFrames: 78000, startChan: 1, numChans: 2, gain: 0.5, destStartFrame: 22050, destination: d,  destGain: 1.0).wait;
    d.query;
    d.play;
}.play
)
//constructing a one second buffer: the first second of each buffer, the mono synth on the right, the piano on the left
(
Routine{
    d.free; d = Buffer.new(s);
    FluidBufCompose.process(s, source: b, numFrames: 44100, numChans: 1, destStartChan: 1, destination: d);
    FluidBufCompose.process(s, source: c, numFrames:44100, numChans:1, destination: d,  destGain: 1.0).wait;
    d.query;
    d.play;
}.play
)
::
