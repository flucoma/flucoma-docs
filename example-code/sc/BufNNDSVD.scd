
code::
(
b = Buffer.read(s,File.realpath(FluidBufNNDSVD.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Nicol-LoopE-M.wav");
~bases = Buffer.new(s);
~activations = Buffer.new(s);
~resynth = Buffer.new(s);
)

//how many bases do I need to decompose the buffer with 90% accuracy
(
Routine{
    FluidBufNNDSVD.process(s, b, ~bases, ~activations, coverage: 0.9, method: 1).wait;
    "% bases".format(~bases.numChannels).postln;
}.play;
)
//check how many bases we are returned:


//try the same process with less accuracy
(
Routine{
    FluidBufNNDSVD.process(s, b, ~bases, ~activations, coverage: 0.5).wait;
    "% bases".format(~bases.numChannels).postln;
}.play
)

//use the bases to run NMF on
FluidBufNMF.process(s, b, resynth: ~resynth, bases: ~bases, activations: ~activations,actMode: 2, components: ~bases.numChannels, action: {\done.postln;})
{PlayBuf.ar(~resynth.numChannels, ~resynth)[2]}.play
::
