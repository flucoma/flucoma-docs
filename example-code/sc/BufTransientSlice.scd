
code::
// load some buffers
(
b = Buffer.read(s,File.realpath(FluidBufTransientSlice.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-AaS-SynthTwoVoices-M.wav");
c = Buffer.new(s);
)

// with basic parameters (wait for the computation time to appear)
(
	Routine{
	t = Main.elapsedTime;
	FluidBufTransientSlice.process(s,b, indices:c).wait;
	(Main.elapsedTime - t).postln;
}.play
)

//check the number of slices
c.query;

//loops over a splice
(
{
    BufRd.ar(1, b,
        Phasor.ar(0,1,
            BufRd.kr(1, c,
                MouseX.kr(0, BufFrames.kr(c) - 1), 0, 1),
            BufRd.kr(1, c,
                MouseX.kr(1, BufFrames.kr(c)), 0, 1),
            BufRd.kr(1,c,
                MouseX.kr(0, BufFrames.kr(c) - 1), 0, 1)), 0, 1);
        }.play;
)

// with everything changed to make it much better, at the cost of computation time (only 5 seconds are processed here, again wait for the (longer) computation time to appear)
(
Routine{
	t = Main.elapsedTime;
	FluidBufTransientSlice.process(s,b, 0, 220500, 0, 1, c, 200, 2048, 1024, 1, 3, 1, 15, 30, 4410).wait;
	(Main.elapsedTime - t).postln;
}.play
)

// play with the same player above to hear the segmentation difference
::

STRONG::A stereo buffer example.::
CODE::

// make a stereo buffer
b = Buffer.alloc(s,88200,2);

// add some stereo clicks and listen to them
((0..3)*22050+11025).do({|item,index| b.set(item+(index%2), 1.0)})

b.play

// create a new buffer as destinations
c = Buffer.new(s);

//run the process on them
(
// with basic params
Routine{
    t = Main.elapsedTime;
    FluidBufTransientSlice.process(s,b, indices: c, threshFwd: 1.2).wait;
    (Main.elapsedTime - t).postln;
}.play
)

// list the indicies of detected attacks - the two input channels have been summed
c.getn(0,c.numFrames,{|item|(item*2).postln;})
::
