
code::
// detrending explained
// define a test signal and a destination buffer
(
b = Buffer.sendCollection(s, Array.fill(44100,{|i| sin(i*pi/ (44100/640)) * ((((79000-i) % 22050).abs / 28000.0) + 0.2)}));
c = Buffer.new(s);
)
// the source is a sinewave that does not go to silence and has sharp-ish amplitude bumps as onsets we try to track
b.play
b.plot

//process with symmetrical thresholds
FluidBufAmpSlice.process(s, b,indices: c,fastRampUp: 5,fastRampDown: 50,slowRampUp: 220,slowRampDown: 220, onThreshold: 10, offThreshold: 10,floor: -60);
c.query
c.getn(0,c.numFrames,{|item|item.postln;})

//beware of multiple triggers at the begining of the 2nd cycle above). A solution: Schmidth triggers
FluidBufAmpSlice.process(s, b,indices: c,fastRampUp: 5,fastRampDown: 50,slowRampUp: 220,slowRampDown: 220, onThreshold: 10, offThreshold: 7,floor: -60);
c.query
c.getn(0,c.numFrames,{|item|item.postln;})

// we got most of them sorted, but there is another solution: minslicelength
FluidBufAmpSlice.process(s, b,indices: c,fastRampUp: 5,fastRampDown: 50,slowRampUp: 220,slowRampDown: 220, onThreshold: 10, offThreshold: 7,floor: -60, minSliceLength: 500);
c.query
c.getn(0,c.numFrames,{|item|item.postln;})
::

STRONG::A musical example.::
CODE::
//load a buffer
(
b = Buffer.read(s,File.realpath(FluidBufAmpSlice.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Nicol-LoopE-M.wav");
c = Buffer.new(s);
)

// slice the samples
FluidBufAmpSlice.process(s,b,indices:c,fastRampUp: 10,fastRampDown: 2205,slowRampUp: 4410,slowRampDown: 4410,onThreshold: 10,offThreshold: 5,floor: -40,minSliceLength: 4410,highPassFreq: 20);
c.query
c.getn(0,c.numFrames,{|item|item.postln;})

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
		var t = Main.elapsedTime;
		var proc = FluidBufAmpSlice.process(s,b, indices: c, fastRampUp: 10,fastRampDown: 2205,slowRampUp: 4410,slowRampDown: 4410, onThreshold: 10,offThreshold: 5);
		proc.wait;
		c.query;
		(Main.elapsedTime - t).postln;
	}.play
)

// list the indicies of detected attacks - the two input channels have been summed.
c.getn(0,c.numFrames,{|item|(item * 2).postln;})
::
