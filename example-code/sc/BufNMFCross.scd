
code::

~path = FluidFilesPath()
b = Buffer.read(s,~path+/+"Nicol-LoopE-M.wav")
t = Buffer.read(s,~path+/+"Tremblay-SA-UprightPianoPedalWide.wav")
o = Buffer.new
FluidBufNMFCross.process(s,t,b,o,windowSize: 2048, action:{"Ding".postln})
//wait for it to be done. It can take a while, depending on the length of your source.
o.play

//The result of the cross synthesis is a hybrid of the source and target sounds. The algorithm tries to match the target spectrum over time using components learned from the source. These parameters affect the reconstruction:
~sparsity = 4; //Avoid reusing a component from the source for this number of time frames
~polyphony = 3; //Avoid overlapping more than this number of source components at the same time
~continuity = 20; //Encourage the reconstruction to use this many temporally consecutive frames from the source

//Using the UGen to run the process can be useful to monitor its progress
(
Routine{
   ~cross = FluidBufNMFCross.process(s,t,b,o,timeSparsity: ~sparsity, polyphony: ~polyphony, continuity: ~continuity, windowSize: 2048);
   defer{{FreeSelfWhenDone.kr(~cross.kr).poll}.play;};
   ~cross.wait;
	\Done.postln;
}.play;
)
o.play
::
