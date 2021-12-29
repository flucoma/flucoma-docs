
code::
// make a buffer of know qualities
b = Buffer.sendCollection(s,0.0.series(0.1,1.0))
// and a destination buffer
c = Buffer(s)
// play with the threshold
FluidBufThresh.process(s, b, destination: c, threshold: 0.5)
// retrieve the buffer and enjoy the results.
c.getn(0,11,{|x|x.round(0.000001).postln;})

// also works in multichannel - explore the following buffer
b = Buffer.sendCollection(s,0.0.series(0.1,2.0).scramble,2)
b.plot.plotMode_(\points)
//process and keep just the top values
FluidBufThresh.process(s, b, destination: c, threshold: 1.6)
//enjoy
c.plot.plotMode_(\points)

//also works with a subset of the input, resizing the output
b = Buffer.sendCollection(s,0.0.series(0.1,3.0).reshape(3,10).flop.flat,3)
b.plot(separately: true).plotMode_(\points)
//process and keep just the top values
FluidBufThresh.process(s, b,startFrame: 3,numFrames: 4,startChan: 1,numChans: 1,destination: c, threshold: 1.6)
//enjoy
c.plot(separately: true).plotMode_(\points)
c.query
c.getn(0,4,{|x|x.round(0.000001).postln;})
::
