strong::Basic Copy::
code::
~src = Buffer.read(s,FluidFilesPath("Tremblay-FMTriDist-M.wav"));

(
~destination = Buffer(s);
FluidBufCompose.processBlocking(s,~src,destination:~destination,action:{
	defer{
		~src.plot;
		~destination.plot;
	};
});
)
::
strong::Mixing::
code::
(
~srcA = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcBassGuit-Melo-M.wav"));
~srcB = Buffer.read(s,FluidFilesPath("Tremblay-AaS-VoiceQC-B2K-M.wav"));
)

// listen separately if you want
~srcA.play;
~srcB.play;

(
fork{
	~destination = Buffer(s);
	[~srcA,~srcB].do{
		arg src;
		FluidBufCompose.processBlocking(s,src,destination:~destination,destGain:1,gain:-6.dbamp);
	};
	s.sync;
	~destination.play;
}
)
::
strong::Subsections::
code::
(
~srcA = Buffer.read(s,FluidFilesPath("Tremblay-SlideChoirAdd-M.wav"));
~srcB = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));
)

// listen separately if you want
~srcA.play;
~srcB.play;

(
fork{
	~destination = Buffer(s);

	// starting at frame 30000, copy 1 second of ~srcB
	FluidBufCompose.processBlocking(s,~srcB,startFrame:30000,numFrames:44100,destination:~destination,destGain:1,gain:-6.dbamp);
	// copy 9000 frames of ~srcA
	FluidBufCompose.processBlocking(s,~srcA,numFrames:9000,destination:~destination,destGain:1,gain:-6.dbamp);

	s.sync;
	~destination.play;
}
)
::
strong::Multichannel::
code::

(
~stereoPiano = Buffer.read(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"));
~synthSounds = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));
)

// copy the mono synth sounds into the R channel of the stereo piano buffer using destStartChan:1
(
FluidBufCompose.processBlocking(s,~synthSounds,destination:~stereoPiano,destGain:1,destStartChan:1,action:{
	~stereoPiano.play;
});
)

// copy just the L channel of the piano into the R channel of the synth sounds
// (because it doesn't have an R channel yet, BufCompose will create one)
(
FluidBufCompose.processBlocking(s,~stereoPiano,destination:~synthSounds,numChans:1,destGain:1,destStartChan:1,action:{
	~synthSounds.play;
});
)

// if numChans is greater than the available channels it will wrap around to the beginning channels, so we can reverse the channels like this:

// original
~stereoPiano.play;

(
~reversed = Buffer(s);
FluidBufCompose.processBlocking(s,~stereoPiano,startChan:1,numChans:2,destination:~reversed,action:{
	~reversed.play;
});
)
::