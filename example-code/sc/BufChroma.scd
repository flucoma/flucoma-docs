
code::

~src = Buffer.read(s,FluidFilesPath("Harker-DS-TenOboeMultiphonics-M.wav"));

// listen if you want
~src.play;

(
fork({
	var win, synth;
	var chroma = Buffer(s);

	FluidBufChroma.processBlocking(s,~src,features:chroma);

	s.sync;

	synth = {
		arg index = 0;
		var chromaVector = BufRd.kr(12,chroma,index,1,1);
		var freqs = 440 * 12.collect{arg i; 2.pow(i/12)};
		var sig = SinOsc.ar(freqs,0,chromaVector);
		Splay.ar(sig);
	}.play;

	win = Window("FluidChroma: click me to hear sines of the chroma analysis",Rect(0,0,1600,400));

	FluidWaveform(~src,featuresBuffer:chroma,parent:win,bounds:win.bounds,stackFeatures:true,standalone:false);

	UserView(win,win.bounds).mouseDownAction_{
		arg view, x, y;
		var index = x.linlin(0,view.bounds.width,0,chroma.numFrames-1).asInteger;
		synth.set(\index,index);
	};

	win.front;
},AppClock)
)

::
strong::Dividing the octave into more than 12 divisions::
code::

// doing a chroma analysis dividing the octvae into 19 equal divisions:

~src = Buffer.read(s,FluidFilesPath("Harker-DS-TenOboeMultiphonics-M.wav"));

// listen if you want
~src.play;

(
fork({
	var win, synth;
	var chroma = Buffer(s);

	FluidBufChroma.processBlocking(s,~src,features:chroma,numChroma:19);

	s.sync;

	synth = {
		arg index = 0;
		var chromaVector = BufRd.kr(chroma.numChannels,chroma,index,1,1);
		var freqs = 440 * chroma.numChannels.collect{arg i; 2.pow(i/chroma.numChannels)};
		var sig = SinOsc.ar(freqs,0,chromaVector);
		Splay.ar(sig);
	}.play;

	win = Window("FluidChroma: click me to hear sines of the chroma analysis",Rect(0,0,1600,400));

	FluidWaveform(~src,featuresBuffer:chroma,parent:win,bounds:win.bounds,stackFeatures:true,standalone:false);

	UserView(win,win.bounds).mouseDownAction_{
		arg view, x, y;
		var index = x.linlin(0,view.bounds.width,0,chroma.numFrames-1).asInteger;
		synth.set(\index,index);
	};

	win.front;
},AppClock)
)

::
