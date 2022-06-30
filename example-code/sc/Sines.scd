
CODE::

~src = Buffer.readChannel(s,FluidFilesPath("Tremblay-BeatRemember.wav"),channels:[0]);

(
~synth = {
	arg which = 0, detectionThreshold = -96, minTrackLen = 15;
	var src = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var sines, residual;
	# sines, residual = FluidSines.ar(src,detectionThreshold:detectionThreshold,minTrackLen:minTrackLen);
	Select.ar(which,[sines,residual]).dup;
}.play;
)

~synth.set(\which,1) // residual
~synth.set(\which,0) // back to sinusoids

// try some different parameters

// tracks can be short but the detection threshold is higher than the default
~synth.set(\detectionThreshold,-40,\minTrackLen,1)

// increase the minimum track length
~synth.set(\detectionThreshold,-40,\minTrackLen,15)

// lower the threshold but increase the track length drastically
~synth.set(\detectionThreshold,-80,\minTrackLen,50)

// increase the threshold drastically but lower the minimum track length
~synth.set(\detectionThreshold,-24,\minTrackLen,1)
::
strong::a little more explanation::
With these settings everything in the sound is considered a sinusoid, even short and quiet peaks.

Because the decomposition is a windowed process, the detected sinusoidal peaks are located in time based on the window of analysis. When the oscillator changes (even slowly) over time we hear the artefact in the residual output.
code::

(
~synth = {
	arg which = 0;
	var stable = SinOsc.ar(69.midicps,0,0.1);
	var oscillating = SinOsc.ar(SinOsc.kr(0.1,0,12,57).midicps,0,0.1);
	var sig = SelectX.ar(which.lag(0.1),[stable,oscillating]);
	var sines, residual;
	# sines, residual = FluidSines.ar(sig,76,-144,-144,-144,1,0,200,1000,0);
	[sines, residual * ((which*40) + 1).lag(0.1)]
}.play
)

~synth.set(\which,1);

~synth.set(\which,0);

::