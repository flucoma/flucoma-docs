strong::Plot the BufOnsetFeature curve along with the indices from BufOnsetSlice::
code::

~src = Buffer.readChannel(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"),channels:[0]);

(
~indices = Buffer(s);
~feature = Buffer(s);
FluidBufOnsetSlice.processBlocking(s,~src,indices:~indices,metric:9,threshold:0.2);
FluidBufOnsetFeature.processBlocking(s,~src,features:~feature,metric:9);
FluidWaveform(~src,~indices,~feature,bounds:Rect(0,0,1600,400),lineWidth:2);
)
::