code::

(
~src = Buffer.readChannel(s,FluidFilesPath("Tremblay-BeatRemember.wav"),channels:[0]);
~sines = Buffer(s);
~residual = Buffer(s);
)

// listen to the original if you want
~src.play;

FluidBufSines.processBlocking(s,~src,sines:~sines,residual:~residual,action:{"done".postln;});

~sines.play;
~residual.play;

// change some parameters

// tracks can be short but the detection threshold is higher than the default
(
FluidBufSines.processBlocking(s,
	~src,
	sines:~sines,
	residual:~residual,
	detectionThreshold:-40,
	minTrackLen:1,
	action:{"done".postln;}
);
)

~sines.play;
~residual.play;

// increase the minimum track length
(
FluidBufSines.processBlocking(s,
	~src,
	sines:~sines,
	residual:~residual,
	detectionThreshold:-40,
	minTrackLen:15,
	action:{"done".postln;}
);
)

~sines.play;
~residual.play;

// lower the threshold but increase the track length drastically
(
FluidBufSines.processBlocking(s,
	~src,
	sines:~sines,
	residual:~residual,
	detectionThreshold:-80,
	minTrackLen:50,
	action:{"done".postln;}
);
)

~sines.play;
~residual.play;

// increase the threshold drastically but lower the minimum track length
(
FluidBufSines.processBlocking(s,
	~src,
	sines:~sines,
	residual:~residual,
	detectionThreshold:-24,
	minTrackLen:1,
	action:{"done".postln;}
);
)

~sines.play;
~residual.play;

::