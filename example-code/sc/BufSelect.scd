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
FluidBufSelect.process(s,b,c,action: {c.query});
c.getToFloatArray(action: {|x|x.round(0.1).postln;});

//more powerful copying, resizing the destination accordingly
FluidBufSelect.process(s,b,c, indices: [1,3], channels: [2,4], action: {c.query});
c.getToFloatArray(action: {|x|x.round(0.1).postln;});

//observe the order can be anything, and -1 (default) passes everything in that dimension
FluidBufSelect.process(s,b,c, indices: [ -1 ] , channels: [3, 1, 4], action: {c.query});
c.getToFloatArray(action: {|x|x.round(0.1).postln;});
::

