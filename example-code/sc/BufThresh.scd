strong::Use with the FluidBufStats `weights` argument.::
code::
::
strong::A basic example to look at the output::
code::
// make a buffer with some values roughly 0 to 5
// and a buffer to write the output of FluidBufThresh into
(
~hundred = Buffer.loadCollection(s,(1..100).log);
~threshed = Buffer(s);
)

// take a look at the values
~hundred.plot;

// apply a threshold of 3
FluidBufThresh.processBlocking(s,~hundred,destination:~threshed,threshold:3);

// take a look at the output
~threshed.plot;

// composite them together (for looking at later)
(
~together = Buffer(s);
FluidBufCompose.processBlocking(s,~hundred,destination:~together);
FluidBufCompose.processBlocking(s,~threshed,destination:~together,destStartChan:1);
)

// plot it
FluidWaveform(featuresBuffer:~together,bounds:Rect(0,0,1600,400),lineWidth:2,normalizeFeaturesIndependently:false);

::
