
CODE::

b = Buffer.readChannel(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"),channels:[0]);

// hear original
b.play;

// process the "harmonic" part separately from the "percussive" part
(
y = {
	arg which = 1;
	var src = PlayBuf.ar(1,b,BufRateScale.kr(b),loop:1);
	var harm, perc, residual;

	// FluidHPSS will always output a resdiual stream, but if using maskingMode 0 or 1, the residual will be silent.
	# harm, perc, residual = FluidHPSS.ar(src,37,11,maskingMode:1);
	harm = PitchShift.ar(harm,pitchRatio:LFDNoise0.kr(1).midiratio);
	harm = Pan2.ar(harm,SinOsc.kr(0.3));
	harm = FreeVerb2.ar(harm[0],harm[1],0.9,0.9,0.1);
	harm + Pan2.ar((PitchShift.ar(perc,pitchRatio:0.2) * 10).softclip * 0.3,LFDNoise0.kr(1));
}.play;
)

// try it with some straight ahead drums:
b = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

// hear original
b.play;

(
fork{

	2.do{
		arg i;

		["Percussive Component Only","Harmonic Component Only"][i].postln;

		y = {
			var src = PlayBuf.ar(1,b,BufRateScale.kr(b));
			FluidHPSS.ar(src,17,31,maskingMode:0)[1-i].dup;
		}.play;

		b.duration.wait;
		1.wait;
	}
}
)

::

STRONG::Masking Modes::

CODE::

//load a soundfile to play
~buf = Buffer.readChannel(s,FluidFilesPath("Tremblay-BeatRemember.wav"),channels:[0]);

// ==================== masking mode = 0: soft mask =======================
// masking mode 0 uses a soft mask to separate the two components
// fewer artefacts, more bleed
(
y = {
	arg which = 0;
	var src = PlayBuf.ar(1,~buf,BufRateScale.kr(~buf),loop:1);
	var harm, perc;
	# harm, perc = FluidHPSS.ar(src,17,31,maskingMode:0);
	Select.ar(which,[src,harm,perc]).dup;
}.play;
)

y.set(\which,1); // just harm
y.set(\which,2); // just perc
y.set(\which,0); // original;


// ==================== masking mode = 1: binary mask =======================
// masking mode 1 uses a binary mask to separate the two components
// more separation, more artefacts
(
y = {
	arg which = 0;
	var src = PlayBuf.ar(1,~buf,BufRateScale.kr(~buf),loop:1);
	var harm, perc;
	# harm, perc = FluidHPSS.ar(src,17,31,maskingMode:1);
	Select.ar(which,[src,harm,perc]).dup;
}.play;
)

y.set(\which,1); // just harm
y.set(\which,2); // just perc
y.set(\which,0); // original;

// ============ masking mode = 2: soft mask (with residual) ===============
// masking mode 2 uses a soft mask to separate the two components
// and also outputs a residual
(
y = {
	arg which = 0;
	var src = PlayBuf.ar(1,~buf,BufRateScale.kr(~buf),loop:1);
	var harm, perc, residual;
	# harm, perc, residual = FluidHPSS.ar(src,17,31,maskingMode:2);
	Select.ar(which,[src,harm,perc,residual]).dup;
}.play;
)

y.set(\which,1); // just harm
y.set(\which,2); // just perc
y.set(\which,3); // just residual
y.set(\which,0); // original

::

STRONG::Latency and Null-Sum Test::

CODE::

~buf = Buffer.readChannel(s,FluidFilesPath("Tremblay-BeatRemember.wav"),channels:[0]);

// add a latency to the processed signal of (((harmFilterSize - 1) * hopSize) + windowSize) samples
// this should output silence (because the null-summing is working)!
{var sig = PlayBuf.ar(1,~buf,loop:1); [FluidHPSS.ar(sig, 17, 31).sum - DelayN.ar(sig, 1, ((((17 - 1) *  512) + 1024) / s.sampleRate))]}.play

::
