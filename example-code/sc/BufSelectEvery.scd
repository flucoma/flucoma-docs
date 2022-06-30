code::
// a buffer with 5 frames and 3 channels,
// where, for the values in the buffer, the tens column
// is the channel, and the ones column is the frame
(
~src = Buffer.loadCollection(s,Array.fill(5,{
	arg frame;
	Array.fill(3,{
		arg chan;
		(chan * 10 ) + frame;
	});
}).flat,3);
)

// print it out and look to check:
(
~src.loadToFloatArray(action:{
	arg fa;
	fa = fa.clump(~src.numChannels).flop;
	fa.do{
		arg chan;
		chan.postln;
	};
});
)

// copy out the odd frames and the even channels
(
~destination = Buffer(s);
FluidBufSelectEvery.processBlocking(s,~src,1,frameHop:2,chanHop:2,destination:~destination,action:{
	~destination.loadToFloatArray(action:{
		arg fa;
		fa = fa.clump(~destination.numChannels).flop;
		fa.do{
			arg chan;
			chan.postln;
		};
	});
});
)
::
strong::Curating Descriptors::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-Iterative-M.wav"));

(
~loudnessbuf = Buffer(s);
~statsbuf = Buffer(s);
~selected = Buffer(s);
FluidBufLoudness.processBlocking(s,~src,features:~loudnessbuf);
FluidBufStats.processBlocking(s,~loudnessbuf,stats:~statsbuf,numChans:1,numDerivs:2);
FluidBufSelectEvery.processBlocking(s,~statsbuf,frameHop:7,destination:~selected);
~selected.loadToFloatArray(action:{
	arg fa;
	["mean loudness", "mean of the 1st derivative of loudness","mean of the 2nd derivative of loudness"].do{
		arg name, i;
		"%\t<-- %".format(fa[i],name).postln;
	};
});
)
::