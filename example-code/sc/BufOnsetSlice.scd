
CODE::
(
//prep some buffers
b = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));
c = Buffer.new(s);
)

(
// with basic params
Routine{
	t = Main.elapsedTime;
	FluidBufOnsetSlice.process(s,b, indices: c, threshold:0.5).wait;
	(Main.elapsedTime - t).postln;
}.play
)

//check the number of slices: it is the number of frames in the transBuf minus the boundary index.
c.query;

//loops over a splice with the MouseX
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
    FluidBufOnsetSlice.process(s,b, indices: c, threshold:0.00001).wait;
    (Main.elapsedTime - t).postln;
}.play
)

// list the indicies of detected attacks - the two input channels have been summed
c.getn(0,c.numFrames,{|item|(item * 2).postln;})
::
