strong::Indexing into the output::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcBassGuit-Melo-M.wav"));

(
{
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var pitch = FluidPitch.kr(sig); // outputs 2 analyses: frequency and confidence
	var stats = FluidStats.kr(pitch,10);
	var means = stats[0]; // stats index 0 is an array of the means
	var stddevs = stats[1]; // stats index 1 is an array of the stddevs
	pitch.poll(label:  "pitch analysis ");
	stats.poll(label:  "stats output   ");
	means.poll(label:  "means          ");
	stddevs.poll(label:"stddevs        ");
	0.poll(label:"-----------------------------------");
	sig;
}.play
)

::
strong::Smoothing a signal::
code::

(
~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcBassGuit-Melo-M.wav"));
~cb = Bus.control(s,2);
)

(
{
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var pitch = FluidPitch.kr(sig); // outputs 2 analyses: frequency and confidence
	var stats = FluidStats.kr(pitch,25);
	var means = stats[0]; // stats index 0 is an array of the means
	var stddevs = stats[1]; // stats index 1 is an array of the stddevs
	Out.kr(~cb,[pitch[1],means[1]]); // write the confidence and the mean (smoothed) confidence to the bus
	sig;
}.play;

~cb.scope(zoom:0);
)

::
strong::Standard Deviation::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-AaS-AcBassGuit-Melo-M.wav"));

// Standard Deviation might provide some insight into moments of *change*
// because there will be a variety of different values in the history
// window being used to compute it
// (more variety in the data = higher standard deviation)
(
{
	var sig = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var pitch = FluidPitch.kr(sig); // outputs 2 analyses: frequency and confidence
	var stats = FluidStats.kr(pitch,25);
	var stddevs = stats[1]; // stats index 1 is an array of the stddevs
	SendReply.kr(Impulse.kr(30),"/stddevs",stddevs);
	sig;
}.play;

OSCdef(\stddevs,{
	arg msg;
	var post = "stddev pitch : ";
	{post = post ++ "*"} ! (msg[3] * 2).asInteger;
	post = post ++ "\nstddev conf  : ";
	{post = post ++ "+"} ! (msg[4] * 200).asInteger;
	post.postln;
	"".postln;
},"/stddevs");
)

::
strong::Specifying "size" using seconds::

Because the parameter size is specified in control rate frames, one might want to be able to specify in seconds and convert to control rate frames before sending the value to the object.
code::

(
~synth = {
	arg size_seconds = 1;
	var sig = LFDNoise0.kr(20);

	// the number of control frames to store and use for
	// statistics = the number of seconds you want / the
	// duration of one control cycle
	var size = size_seconds / ControlDur.ir;

	var stats = FluidStats.kr(sig,size);
	var mean = stats[0][0];
	[sig,mean]
}.scope(zoom:0);
)

~synth.set(\size_seconds,0.01);
~synth.set(\size_seconds,10);
~synth.set(\size_seconds,1);

::