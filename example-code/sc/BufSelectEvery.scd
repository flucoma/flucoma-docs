Didactic
code::
//send a known collection where the value of each frame in each channel is encoded
//chan
b = Buffer.sendCollection(s,30.collect{|x| x.mod(6) + (x.div(6) * 0.1)},6)
//check the ranges (thus showing a plotter error...)
b.plot(separately: true).plotMode_(\points)
//you can also check the collection itself if in doubt
b.getToFloatArray(action: {|x|x.round(0.1).postln;});

//let's make a destination buffer
c = Buffer(s);

//using default values, we copy everything:
FluidBufSelectEvery.process(s,b, destination: c, action: {c.query});
c.getToFloatArray(action: {|x|x.round(0.1).postln;});

//more powerful copying, resizing the destination accordingly
FluidBufSelectEvery.process(s,b, destination: c, frameHop: 2, chanHop: 3, action: {c.query});
c.getToFloatArray(action: {|x|x.round(0.1).postln;});

//source buffer boundaries still apply before the hopping selection
FluidBufSelectEvery.process(s,b, startFrame: 1, numFrames: 3, startChan: 2, numChans: 3, destination: c, frameHop: 1, chanHop: 2, action: {c.query});
c.getToFloatArray(action: {|x|x.round(0.1).postln;});
::
