
code::
s.reboot
(
b = Buffer.read(s,File.realpath(FluidBufSTFT.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Nicol-LoopE-M.wav");
m = Buffer.new;
p = Buffer.new;
r = Buffer.new;
)

(
fork{
	FluidBufSTFT.process(s,source:b,magnitude:m,phase:p).wait;
	FluidBufSTFT.process(s,magnitude:m,phase:p,resynth:r,inverse:1).wait;
	"Done".postln;
}
)

{ PlayBuf.ar(1,r); }.play

//nullsum
{ PlayBuf.ar(1,r) - PlayBuf(1,b); }.play

//draw the magnitudes as a greyscale spectrogram
// make the image
i = Image.new(m.numFrames, m.numChannels)

//retreive the image and assign to pixels
(
m.loadToFloatArray(action: {|x|
	var mod = m.numChannels;
	{
		x.do{
			|val, index|
			i.setColor(Color.gray(val), index.div(mod), mod - 1 - index.mod(mod));
		};
		i.plot("spectrogram", showInfo: false);
	}.fork(AppClock)
});
)
::
