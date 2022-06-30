CODE::

~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));

// slice with basic parameters
(
~indices = Buffer(s);
FluidBufOnsetSlice.processBlocking(s,~src,metric:9,indices:~indices,threshold:0.3,action:{
	"found % slice points".format(~indices.numFrames).postln;
	"with an average length of % seconds per slice".format(~src.duration / ~indices.numFrames).postln;
});
)

// display
FluidWaveform(~src,~indices);

//loops over a slice from onset to the next slice point using MouseX to choose which
(
{
	var gate_index = MouseX.kr(0,~indices.numFrames-1).poll(label:"slice index");
	var start = BufRd.kr(1,~indices,gate_index,1,1);
	var end = BufRd.kr(1,~indices,gate_index+1,1,1);
	var phs = Phasor.ar(0,BufRateScale.ir(~src),start,end);
	BufRd.ar(1,~src,phs,1,4).dup;
}.play;
)

::