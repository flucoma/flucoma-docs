strong::Plot the BufAmpFeature curve along with the indices from BufAmpSlice::
code::
~drums = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
~indices = Buffer(s);
~feature = Buffer(s);
FluidBufAmpSlice.processBlocking(s,~drums,indices:~indices,fastRampUp:100,fastRampDown:100,slowRampUp:4410,slowRampDown:4410,onThreshold:10,offThreshold:0,floor:-40);
FluidBufAmpFeature.processBlocking(s,~drums,features:~feature,fastRampUp:10,fastRampDown:10,slowRampUp:4410,slowRampDown:4410,floor:-60);
FluidWaveform(~drums,~indices,~feature,bounds:Rect(0,0,1600,400));
)

::