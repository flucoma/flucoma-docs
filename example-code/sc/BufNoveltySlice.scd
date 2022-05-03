
code::
// load some buffers
(
b = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcousticStrums-M.wav"));
c = Buffer.new(s);
)

(
// with basic params, with a minimum slight length to avoid over
Routine{
	t = Main.elapsedTime;
	FluidBufNoveltySlice.process(s,b, indices: c, threshold:0.4,filterSize: 4, minSliceLength: 8).wait;
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

STRONG::Examples of the impact of the filterSize::

	CODE::
// load some buffers
(
b = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcousticStrums-M.wav"));
c = Buffer.new(s);
)

// process with a given filterSize
(
Routine{
    FluidBufNoveltySlice.process(s,b, indices: c, kernelSize:31, threshold:0.1, filterSize:1).wait;
//check the number of slices: it is the number of frames in the transBuf minus the boundary index.
    c.query;
}.play;
)
//play slice number 3
(
{
    BufRd.ar(1, b,
        Line.ar(
            BufRd.kr(1, c, DC.kr(3), 0, 1),
            BufRd.kr(1, c, DC.kr(4), 0, 1),
            (BufRd.kr(1, c, DC.kr(4)) - BufRd.kr(1, c, DC.kr(3), 0, 1) + 1) / s.sampleRate),
        0,1);
}.play;
)

// change the filterSize in the code above to 4. Then to 12. Listen in between to the differences.

// What's happening? In the first instance (filterSize = 1), the novelty line is jittery and therefore overtriggers on the arpegiated guitar. We also can hear attacks at the end of the segment. Setting the threshold higher (like in the 'Basic Example' pane) misses some more subtle variations.

// So in the second settings (filterSize = 4), we smooth the novelty line a little, which allows us to catch small differences that are not jittery. It also corrects the ending cutting by the same trick: the averaging of the sharp pick is sliding up, crossing the threshold slightly earlier.

// If we smooth too much, like the third settings (filterSize = 12), we start to loose precision and miss attacks. Have fun with different values of theshold then will allow you to find the perfect segment for your signal.
::

STRONG::A stereo buffer example.::
CODE::

// make a stereo buffer
b = Buffer.alloc(s,88200,2);

// add some stereo clicks and listen to them
((0..3)*22050+11025).do({|item,index| b.set(item+(index%2), 1.0)});
b.play

// create a new buffer as destinations
c = Buffer.new(s);

//run the process on them
(
// with basic params
Routine{
    t = Main.elapsedTime;
    FluidBufNoveltySlice.process(s,b, indices: c, threshold:0.3).wait;
    (Main.elapsedTime - t).postln;
}.play
)

// list the indicies of detected attacks - the two input channels have been summed
c.getn(0,c.numFrames,{|item|(item * 2).postln;})
::
