code::
~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

// listen if you want
~src.play;

(
var specbuf = Buffer(s);
FluidBufSpectralShape.processBlocking(s,~src,features:specbuf);
specbuf.loadToFloatArray(action:{
	arg fa;
	var spec = fa.clump(specbuf.numChannels);
	var win;

	defer{
		win = Window("FluidBufSpectralShape: click me to hear sines of the spec analysis",Rect(0,0,1600,400));

		FluidWaveform(~src,featuresBuffer:specbuf,parent:win,bounds:win.bounds,stackFeatures:true,standalone:false);

		UserView(win,win.bounds).mouseDownAction_{
			arg view, x, y;
			var index = x.linlin(0,view.bounds.width,0,spec.size-1).asInteger;
			"analysis frame: %".format(index).postln;
			FluidSpectralShape.features.do{
				arg feat, i;
				"\t%: %".format(feat.asString.padRight(10),spec[index][i]).postln;
			};
			"".postln;
		};

		win.front;
	}
});
)
::
strong::Using "select"::
By passing an array of symbols to the select argument you can choose to output only a subset of the analyses. The options are \centroid, \spread, \skewness, \kurtosis, \rolloff, \flatness, \and crest. If nothing is specified, the object will return all the analyses. The analyses will always appear in their normal order, this argument just allows for a selection of them to be returned. Reordering the options in this argument will not reorder how the analyses are returned.
code::

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

// listen if you want
~src.play;

// change this if you want to see other selected analyses
~selections = [\centroid,\spread,\flatness];

(
var specbuf = Buffer(s);
FluidBufSpectralShape.processBlocking(s,~src,features:specbuf,select:~selections);
specbuf.loadToFloatArray(action:{
	arg fa;
	var spec = fa.clump(specbuf.numChannels);
	var win;

	defer{
		win = Window("FluidBufSpectralShape: click me to hear sines of the spec analysis",Rect(0,0,1600,400));

		FluidWaveform(~src,featuresBuffer:specbuf,parent:win,bounds:win.bounds,stackFeatures:true,standalone:false);

		UserView(win,win.bounds).mouseDownAction_{
			arg view, x, y;
			var index = x.linlin(0,view.bounds.width,0,spec.size-1).asInteger;
			"analysis frame: %".format(index).postln;
			~selections.do{
				arg feat, i;
				"\t%: %".format(feat.asString.padRight(10),spec[index][i]).postln;
			};
			"".postln;
		};

		win.front;
	}
});
)

::