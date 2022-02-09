
code::
// define a test signal and a destination buffer
(
    b = Buffer.sendCollection(s, Array.fill(44100,{|i| sin(i*pi/ (44100/640)) * (sin(i*pi/ 22050)).abs}));
    c = Buffer.new(s);
)
b.play
b.plot
//basic tests: threshold sanity
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//basic tests: threshold hysteresis
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -16)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//basic tests: threshold min slice
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minSliceLength:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//basic tests: threshold min silence
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minSilenceLength:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//mid tests: threshold time hysteresis on
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minLengthAbove:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//mid tests: threshold time hysteresis off
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minLengthBelow:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//mid tests: threshold with lookBack
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, lookBack:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//mid tests: threshold with lookAhead
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, lookAhead:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//mid tests: threshold with asymetrical lookBack and lookAhead
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, lookBack:221, lookAhead:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})
::

STRONG::A musical example.::
CODE::
//load a buffer
(
    b = Buffer.read(s, FluidFilesPath("Nicol-LoopE-M.wav"));
    c = Buffer.new(s);
)

// slice the samples
(
Routine{
    FluidBufAmpGate.process(s, b, indices:c, rampUp:110, rampDown:2205, onThreshold:-27, offThreshold: -31, minSilenceLength:1100, lookBack:441, highPassFreq:40).wait;
    c.query;
    c.getn(0,c.numFrames*2,{|item|item.postln;});
    //reformatting to read the onsets and offsets as pairs
    c.getn(0,c.numFrames*2,{|items|items.reshape(c.numFrames,2).do({|x| x.postln});});
}.play
)
//loops over a splice with the MouseX, taking the respective onset and offset of a given slice
(
    {
        BufRd.ar(1, b,
            Phasor.ar(0,1,
                BufRd.kr(2, c,
                    MouseX.kr(0, BufFrames.kr(c)), 0, 1)[0],
                BufRd.kr(2, c,
                    MouseX.kr(1, BufFrames.kr(c)), 0, 1)[1],
                BufRd.kr(2,c,
                    MouseX.kr(0, BufFrames.kr(c)), 0, 1)[0]
        ), 0, 1);
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
        var proc= FluidBufAmpGate.process(s, b, indices: c, rampUp:1, rampDown:10, onThreshold: -30);
        proc.wait;
        (Main.elapsedTime - t).postln;
    }.play
)

// list the indicies of detected attacks - the two input channels have been summed. The two channels of the output, respectively onset and offset indices, are interleaved as this is the SuperCollider buffer data formatting
c.getn(0,c.numFrames*2,{|item|(item*2).postln;})
// a more readable version: deinterleave onsetand offset
c.getn(0,c.numFrames*2,{|items|items.reshape(c.numFrames,2).do({|x| (x*2).postln});})
::
