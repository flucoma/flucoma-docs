
code::FluidNMFMorph:: relies on preexisting NMF analyses to generate variations between sounds. Produce these using link::Classes/FluidBufNMF::

code::
//read some audio
(
~src1 = Buffer.readChannel(s,FluidFilesPath("Nicol-LoopE-M.wav"),channels:[0]); //some drums
~src2 = Buffer.readChannel(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"),channels:[0]);//some piano

~src1Bases = Buffer(s);
~src2Bases = Buffer(s);
~src1Activations = Buffer(s);
~src2Activations = Buffer(s);
)

//nmf analyses (wait for this to complete!)
(
FluidBufNMF.processBlocking(s,~src1,bases:~src1Bases,activations:~src1Activations,components:5, action:{"Analysed Source 1".postln});
FluidBufNMF.processBlocking(s,~src2,bases:~src2Bases,activations:~src2Activations, components:4, action:{"Analysed Source 2".postln});
)

(
~synth = { |source, target, activations, autoassign|
	FluidNMFMorph.ar(source,target,activations,autoassign,MouseX.kr).dup * 80
}.play(s,args:[\source,~src1Bases,\target,~src2Bases,\activations,~src1Activations,\autoassign,1]);
)

// Change the actvations
// when changing the activations, one needs to change the 'autoassign' control to update the process
~synth.set(\activations, ~src2Activations, \autoassign,0);
~synth.set(\autoassign,1);

::
