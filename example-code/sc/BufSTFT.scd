
code::

s.boot;

~src = Buffer.read(s,FluidFilesPath("Olencki-TenTromboneLongTones-M.wav"));

~src.play;

// see the spectrogram of magnitudes
(
~mags = Buffer(s);
~phases = Buffer(s);
FluidBufSTFT.processBlocking(s,~src,magnitude:~mags,phase:~phases,action:{
	defer{
		FluidWaveform(imageBuffer:~mags,imageColorScheme:1,imageColorScaling:1);
	};
});
)

// the phases are less useful perhaps...
(
FluidWaveform(imageBuffer:~phases,imageColorScheme:1,imageColorScaling:0);
)

// transform the magnitudes in the frequency domain for the spectral adjustments
(
~mags = Buffer(s);
~phases = Buffer(s);
FluidBufSTFT.processBlocking(s,~src,magnitude:~mags,phase:~phases);
~mags.loadToFloatArray(action:{
	arg mags;
	mags = mags.clump(~mags.numChannels); // clump into analysis frames
	mags = mags.collect{ // collect all the analysis frames
		arg frame, idx;
		frame.collect{
			// in each frame, multiply each value by a multiplier (the nested math here is causing
			// it to do some modulation over time as well as frequency... take a listen
			arg mag, bin;
			mag * ((bin+(idx * 0.7)) * 0.01 * pi).sin.abs.pow(3);
		};
	};
	~mags.loadCollection(mags.flat,action:{

		~resynth = Buffer(s);
		FluidBufSTFT.processBlocking(s,magnitude:~mags,phase:~phases,resynth:~resynth,inverse:1,action:{

			"playing resynth".postln;

			~resynth.postln;
			defer{FluidWaveform(~resynth)};
			~resynth.play;
		});
	});
});
)
::