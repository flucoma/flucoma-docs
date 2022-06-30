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

// now we'll copy out just frames 0, 2, and 3 out of channels 0 and 2
(
~destination = Buffer(s);
FluidBufSelect.processBlocking(s,~src,~destination,[0,2,3],[0,2],action:{
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

// also, it can rearrange channels and indices for you!
(
~destination = Buffer(s);
FluidBufSelect.processBlocking(s,~src,~destination,[0,3,2],[2,0],action:{
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
strong::Curating Descriptor Data::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-Iterative-M.wav"));

(
~descriptors = [0,1,5]; // channels for centroid, spread, and flatness
~stats = [5,6]; // indices for mid and low percentiles (the default will be median and maximum)
~specbuf = Buffer(s);
~statsbuf = Buffer(s);
~selected = Buffer(s);
FluidBufSpectralShape.processBlocking(s,~src,features:~specbuf);
FluidBufStats.processBlocking(s,~specbuf,stats:~statsbuf);
FluidBufSelect.processBlocking(s,~statsbuf,~selected,~stats,~descriptors);
~selected.loadToFloatArray(action:{
	arg fa;
	fa = fa.clump(~selected.numChannels).flop;
	"\t\t\tmedian\t\t\t\tmaximum".postln;
	["centroid","spread  ","flatness"].do{
		arg name, i;
		"% : %".format(name,fa[i]).postln;
	};
});
)
::