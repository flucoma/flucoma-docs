// =============== decompose some sounds ===============

// let's decompose the drum loop that comes with the FluCoMa extension:
~drums = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

// hear the original mono sound file to know what we're working with
~drums.play;

// an empty buffer for the decomposed components to be written into:
~resynth = Buffer(s);

// how many components we want FluidBufNMF to try to decompose the buffer into:
~n_components = 2;

// process it:
FluidBufNMF.processBlocking(s,~drums,resynth:~resynth,components:~n_components,action:{"done".postln;});

// once it is done, play the separated components one by one (with a second of silence in between)
(
fork{
	~n_components.do{
		arg i;
		"decomposed part #%".format(i+1).postln;
		{
			PlayBuf.ar(~n_components,~resynth,BufRateScale.ir(~resynth),doneAction:2)[i].dup;
		}.play;
		(~drums.duration + 1).wait;
	}
};
)

// ======== now let's try it with three components. =========
// make a guess as to what you think you'll hear

~n_components = 3;
// process it:
FluidBufNMF.processBlocking(s,~drums,resynth:~resynth,components:~n_components,action:{"done".postln;});

(
fork{
	~n_components.do{
		arg i;
		"decomposed part #%".format(i+1).postln;
		{
			PlayBuf.ar(~n_components,~resynth,BufRateScale.ir(~resynth),doneAction:2)[i].dup;
		}.play;
		(~drums.duration + 1).wait;
	}
};
)

// you may have guessed that it would separate out the three components into: (1) snare, (2) hihat, and (3) kick
// and it might have worked! but it may not have, and it won't provide the same result every time because it
// starts each process from a stochastic state (you can seed this state if you want...see below).

// ====== bases and activations ========

// first, let's make two new buffers called...
~bases = Buffer(s);
~activations = Buffer(s);
~n_components = 2; // return to 2 components for this example

// and we'll explicitly pass these into the process
FluidBufNMF.processBlocking(s,~drums,bases:~bases,activations:~activations,resynth:~resynth,components:~n_components,action:{"done".postln;});

// now we can plot them (because this process starts from a stochastic state, your results may vary!):
FluidWaveform(~drums,featureBuffer:~activations,bounds:Rect(0,0,1200,300));
// the bases are a like a spectral template that FluidBufNMF has found in the source buffer
// in one you should see one spectrum that resembles a snare spectrum (the resonant tone of the snare
// in the mid range) and another that resembles the kick + hihat we heard earlier (a large peak in the very
// low register and some shimmery higher stuff)

FluidWaveform(featureBuffer:~bases,bounds:Rect(0,0,1200,300));
// the activations are the corresponding loudness envelope of each base above. It should like an amplitude
// envelope follower of the drum hits in the corresponding bases.

// FluidBufNMF then uses the individual bases with their corresponding activations to resynthesize the sound of just
// component.
// the buffer passed to `resynth` will have one channel for each component you've requested

~resynth.numChannels
~resynth.play;

// ======== TODO: seeding activations and bases ======

// ======== to further understand NMF's bases and activations, consider one more object: FluidNMFFilter ==========
// FluidNMFFilter will use the bases (spectral templates) of a FluidBufNMF analysis to filter (i.e., decompose) real-time audio

// for example, if we use the bases from the ~drums analysis above, it will separate the snare from the kick & hihat like before
// this time you'll hear one in each stereo channel (again, results may vary)

(
{
	var src = PlayBuf.ar(1,~drums,BufRateScale.ir(~drums),doneAction:2);
	var sig = FluidNMFFilter.ar(src,~bases,2);
	sig;
}.play;
)

// if we play a different source through FluidNMFFilter, it will try to decompose that real-time signal according to the bases
// it is given (in our case the bases from the drum loop)
~song = Buffer.readChannel(s,FluidFilesPath("Tremblay-beatRemember.wav"),channels:[0]);

(
{
	var src = PlayBuf.ar(1,~song,BufRateScale.ir(~song),doneAction:2);
	var sig = FluidNMFFilter.ar(src,~bases,2);
	sig;
}.play;
)

// what gets "NMF Filtered" to the left? to the right? how do they resemble the bases from the drum loop?

// ========= the activations could also be used as an envelope through time ===========
(
{
	var activation = PlayBuf.ar(2,~activations,BufRateScale.ir(~activations),doneAction:2);
	var sig = WhiteNoise.ar(0.dbamp) * activation;
	sig;
}.play;
)

// note that the samplerate of the ~activations buffer is not a usual one...
~activations.sampleRate
// this is because each frame in this buffer doesn't correspond to one audio sample, but instead to one
// hopSize, since these values are derived from an FFT analysis
// so it is important to use BufRateScale (as seen above) in order to make sure they play back at the
// correct rate

// if we control the amplitude of the white noise *and* send it through FluidNMFFilter, we'll get something
// somewhat resembles both the spectral template and loudness envelope of the bases of the original
// (of course it's also good to note that the combination of the *actual* bases and activations is how
// FluidBufNMF creates the channels in the resynth buffer which will sound much better than this
// filtered WhiteNoise version)
(
{
	var activation = PlayBuf.ar(2,~activations,BufRateScale.ir(~activations),doneAction:2);
	var sig = WhiteNoise.ar(0.dbamp);
	sig = FluidNMFFilter.ar(sig,~bases,2) * activation;
	sig;
}.play;
)