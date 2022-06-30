code::

~raw = Buffer.loadCollection(s,(1..5));

(
~scaled = Buffer(s);
FluidBufScale.processBlocking(s,~raw,destination:~scaled,inputLow:1,inputHigh:5,outputLow:0,outputHigh:1,action:{
	~raw.getn(0,5,{
		arg vals;
		"raw:    %".format(vals).postln;
	});

	~scaled.getn(0,5,{
		arg vals;
		"scaled: %".format(vals).postln;
	});
});
)
::
strong::With Clipping::
code::

~raw = Buffer.loadCollection(s,(1..5));

(
~scaled = Buffer(s);
FluidBufScale.processBlocking(s,~raw,destination:~scaled,inputLow:1,inputHigh:4,outputLow:0,outputHigh:1,clipping:3,action:{
	~raw.getn(0,5,{
		arg vals;
		"raw:    %".format(vals).postln;
	});

	~scaled.getn(0,5,{
		arg vals;
		"scaled: %".format(vals).postln;
	});
});
)
::