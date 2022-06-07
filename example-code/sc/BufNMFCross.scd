code::

(
~target = Buffer.readChannel(s,FluidFilesPath("Nicol-LoopE-M.wav"),channels:[0]);
~source = Buffer.readChannel(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"),channels:[0]);
~output = Buffer(s);
)

FluidBufNMFCross.processBlocking(s,~source,~target,~output,action:{"done".postln})
//wait for it to be done. It can take a while, depending on the length of your source.
~output.play;

//Using the UGen to run the process can be useful to monitor its progress
(
Routine{
	~cross = FluidBufNMFCross.process(s,~source,~target,~output,timeSparsity: 4, polyphony: 3, continuity: 20, windowSize: 2048);

	{
		FreeSelfWhenDone.kr(~cross.kr).poll;
	}.play;

	~cross.wait;

	"done".postln;

}.play;
)

~output.play;
::
