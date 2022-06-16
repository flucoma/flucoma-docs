code::

// a buffer with 5 frames and 3 channels,
// where, for the values in the buffer, the tens column
// is the channel, and the ones column is the frame
(
~src = Buffer.loadCollection(s,Array.fill(5,{
	arg frame;
	Array.fill(3,{
		arg chan;
		((chan+1) * 10 ) + frame + 1;
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

::

