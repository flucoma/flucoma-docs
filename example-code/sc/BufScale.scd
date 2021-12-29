
code::
(
Routine{
    // make a buffer of known qualities
    b = Buffer.sendCollection(s,1.0.series(1.1,2.0));
    // and a destination buffer
    c = Buffer(s);
    // play with the scaling
    FluidBufScale.process(s, b, destination: c, inputLow: 0, inputHigh: 1, outputLow: 20, outputHigh:10).wait;
    // retrieve the buffer and enjoy the results.
	c.getn(0,10,{|x|x.round(0.000001).postln;})
}.play
)

// also works in multichannel - explore the following buffer

//process
(
Routine{
    b = Buffer.sendCollection(s,-10.0.series(-9,10.0).scramble,2);
    c = Buffer(s);
    s.sync;
    defer{b.plot(bounds:Rect(400,400,400,400)).plotMode_(\points).bounds};
    FluidBufScale.process(s, b, destination: c, inputLow: -20, inputHigh: 20, outputLow: 0, outputHigh:1).wait;
    //enjoy - same shape, different range
    defer{c.plot(bounds:Rect(800,400,400,400)).plotMode_(\points)};
}.play;
)

//also works with a subset of the input, resizing the output
(
Routine{
    b = Buffer.sendCollection(s,0.0.series(0.1,3.0).reshape(3,10).flop.flat,3);
    c = Buffer(s);
    s.sync;
    defer{b.plot(separately: true,bounds:Rect(400,400,400,400)).plotMode_(\points)};
    //process
    FluidBufScale.process(s, b, startFrame: 3,numFrames: 4,startChan: 1,numChans: 1, destination: c, inputLow: 0, inputHigh: 3, outputLow: 0, outputHigh:1).wait;
    //enjoy
    c.query;
    c.getn(0,4,{|x|x.postln;});
    defer{c.plot(separately: true,bounds:Rect(800,400,400,400)).plotMode_(\points)};
}.play
)
::


