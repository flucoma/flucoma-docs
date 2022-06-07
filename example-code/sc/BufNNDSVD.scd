
code::

(
~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));
~bases = Buffer.new(s);
~activations = Buffer.new(s);
~resynth = Buffer.new(s);
)

//how many bases do I need to decompose the buffer while accounting for 90% of the variance?
(
Routine{
    FluidBufNNDSVD.process(s, ~src, ~bases, ~activations, coverage: 0.9, method: 1).wait;
    "% bases".format(~bases.numChannels).postln;
}.play;
)

//try the same process with less of the variance preserved
(
Routine{
    FluidBufNNDSVD.process(s, ~src, ~bases, ~activations, coverage: 0.5).wait;
    "% bases".format(~bases.numChannels).postln;
}.play
)

// peek at the bases
~bases.plot;

//use the bases to run NMF on
FluidBufNMF.process(s, ~src, resynth: ~resynth, resynthMode:1, bases: ~bases, basesMode:1, activations: ~activations, components: ~bases.numChannels, action: {"done".postln;})

// peek at the components
FluidWaveform(~resynth,bounds:Rect(0,0,1000,1000));

// listen to component index 2:
(
{
	PlayBuf.ar(~resynth.numChannels, ~resynth)[2]
}.play
)
::
