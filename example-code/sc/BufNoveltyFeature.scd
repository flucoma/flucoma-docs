strong::Plot the BufNoveltyFeature curve along with the indices from BufNoveltySlice::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));

(
~indices = Buffer(s);
~feature = Buffer(s);
FluidBufNoveltySlice.processBlocking(s,~src,indices:~indices,algorithm:1,kernelSize:5,threshold:1.1);
FluidBufNoveltyFeature.processBlocking(s,~src,features:~feature,algorithm:1,kernelSize:5);
FluidWaveform(~src,~indices,~feature,bounds:Rect(0,0,1600,400));
)
::