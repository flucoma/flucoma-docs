
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcousticStrums-M.wav"));

// blue is loudness dBFS, orange is true peak dBFS
(
~loudness = Buffer(s);
FluidBufLoudness.processBlocking(s,~src,features:~loudness);
FluidWaveform(~src,featuresBuffer:~loudness,bounds:Rect(0,0,1600,400),stackFeatures:true);
~src.play;
)

::
strong::Getting some useful loudness stats on an audio file (that is in a Buffer)::
As a result of the loudness wars, a statistical understanding of the loudness of an audio file (such as a rendered track) may be useful. Here are some ways you might use FluidBufLoudness this way.

The EBU standard specifies that the window should be 400ms long, and update every 100ms, for instantaneous loudness. Here we set the windowSize and hopSize appropriately using the sample rate of the source buffer.
code::

// stereo song
~src = Buffer.read(s,FluidFilesPath("Tremblay-beatRemember.wav"));

(
~loudness = Buffer(s);
FluidBufLoudness.processBlocking(s,~src,features:~loudness,windowSize:~src.sampleRate*0.4,hopSize:~src.sampleRate*0.1);
~stats = Buffer(s);
FluidBufStats.processBlocking(s,~loudness,stats:~stats);
~stats.loadToFloatArray(action:{
	arg fa;
	fa = fa.clump(~stats.numChannels).flop;
	"L channel mean   loudness:  % dB".format(fa[0][0]).postln;
	"L channel median loudness:  % dB".format(fa[0][5]).postln;
	"L channel max    true peak: % dB".format(fa[1][6]).postln;

	"R channel mean   loudness:  % dB".format(fa[2][0]).postln;
	"R channel median loudness:  % dB".format(fa[2][5]).postln;
	"R channel max    true peak: % dB".format(fa[3][6]).postln;
});
)

::