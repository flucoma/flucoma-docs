
code::
//Didactic:
//Make 2 sinewave sources to be interpolated
(
b = Buffer.loadCollection(s, FloatArray.fill(44100, {|a|(a / pi).sin * 0.1}));
c = Buffer.loadCollection(s, FloatArray.fill(44100, {|a|(a / pi / 2).sin * 0.02}));
d = Buffer.new
)

//make an sound interpolating their spectrum
FluidBufAudioTransport.process(s,b,source2:c,destination:d,interpolation:0.5,action:{"Ding".postln})

// listen to the source and the result
b.play
c.play
d.play

// note that the process is quantized by the spectral bins. For an example of the pros and cons of these settings on this given process, please see the realtime FluidAudioTransport helpfile.

// more interesting sources: two cardboard bowing gestures
(
b = Buffer.read(s,FluidFilesPath("Green-Box641.wav"));
c = Buffer.read(s,FluidFilesPath("Green-Box639.wav"));
d = Buffer.new
)

// listen to the source
b.play
c.play

// process and listen
FluidBufAudioTransport.process(s,b,source2:c,destination:d,interpolation:0.5,action:{"Ding".postln})
d.play
// try various interpolation factors (0.1 and 0.9 are quite good
::
