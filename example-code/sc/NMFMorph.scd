
code::FluidNMFMorph:: relies on preexisting NMF analyses to generate variations between sounds. We can produce these using link::Classes/FluidBufNMF::

code::
//read some audio
(
~src1 = Buffer.readChannel(s,FluidFilesPath("Nicol-LoopE-M.wav"),channels:[0]); //some drums
~src2 = Buffer.readChannel(s,FluidFilesPath("Tremblay-SA-UprightPianoPedalWide.wav"),channels:[0]);//some piano

~src1Bases = Buffer.new;
~src2Bases = Buffer.new;
~src1Activations = Buffer.new;
~src2Activations = Buffer.new;
)
//nmf analyses
(
FluidBufNMF.process(s,~src1,bases:~src1Bases,activations:~src1Activations,components:5, action:{"Analysed Source 1".postln});
FluidBufNMF.process(s,~src2,bases:~src2Bases,activations:~src2Activations, components:5, action:{"Analysed Source 2".postln});
)

(
~morph = { |source, target, activations, interp, autoassign|
	FluidNMFMorph.ar(source,target,activations,autoassign,interp) * 80
};
)

~synth = ~morph.play(s,args:[\source,~src1Bases,\target,~src2Bases,\activations,~src2Activations,\interp,0.5,\autoassign,1]);

//Play with different interpolation values
~synth.set(\interp,0.0);
~synth.set(\interp,1.0);
::
warning::The following parameters current require one to change the 'autoassign' control to update the process::
code::
//Change the actvations
~synth.set(\activations, ~src1Activations, \autoassign,0);
~synth.set(\autoassign,1);
~synth.set(\activations, ~src2Activations, \autoassign,0);
~synth.set(\autoassign,1);

//Swap source and target
~synth.set(\source,~src2Bases,\target,~src1Bases, \autoassign,0);
~synth.set(\autoassign,1);
::
