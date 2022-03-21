strong::Use with the FluidBufStats `weights` argument.:: Using the pitch confidence value of the FluidBufPitch analysis to weight the statistical analysis of the pitch value can improve the estimation of pitch (as the mean or median). By using FluidBufThresh, we can ensure that any pitch confidence values below a specified threshold will be "zeroed out" so their weight will be zero when calculating FluidBufStats.
code::

~scratchy = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));

~scratchy.play;

(
~pitch_analysis = Buffer(s);
FluidBufPitch.processBlocking(s,~scratchy,features:~pitch_analysis);
)

// look at the pitch analysis:
FluidWaveform(~scratchy,featuresBuffer:~pitch_analysis,stackFeatures:true,bounds:Rect(0,0,1600,400));

// get the median pitch
(
~pitch_stats = Buffer(s);
FluidBufStats.processBlocking(s,~pitch_analysis,numChans:1,stats:~pitch_stats);
~pitch_stats.loadToFloatArray(action:{
	arg fa;
	~median = fa[5];
	~median.postln;
});
)

// hear does it match? (not great)
(
~scratchy.play;
{SinOsc.ar(~median,0,0.01)}.play;
)

// use buf thresh to zero out all confidence values below a threshold:
(
~threshed_conf = Buffer(s);
FluidBufThresh.processBlocking(s,~pitch_analysis,startChan:1,destination:~threshed_conf,threshold:0.99);
)

// look at the thresholded values. (some will appear to not actually reach above the threshold...this is due to
// the interpolation happening for the drawing)
FluidWaveform(~scratchy,featuresBuffer:~threshed_conf,bounds:Rect(0,0,1600,400));

// now that anything below the threshold has become a zero, this will be useful for weighting the BufStats analysis
(
~pitch_stats = Buffer(s);
FluidBufStats.processBlocking(s,~pitch_analysis,numChans:1,stats:~pitch_stats,weights:~threshed_conf);
~pitch_stats.loadToFloatArray(action:{
	arg fa;
	~median = fa[5];
	~median.postln;
});
)

// does it match better? (it does)
(
~scratchy.play;
{SinOsc.ar(~median,0,0.01)}.play;
)

::
strong::A basic example to look at the output::
code::
// make a buffer with some values roughly 0 to 5
// and a buffer to write the output of FluidBufThresh into
(
~hundred = Buffer.loadCollection(s,(1..100).log);
~threshed = Buffer(s);
)

// take a look at the values
~hundred.plot;

// apply a threshold of 3
FluidBufThresh.processBlocking(s,~hundred,destination:~threshed,threshold:3);

// take a look at the output
~threshed.plot;

// composite them together (for looking at later)
(
~together = Buffer(s);
FluidBufCompose.processBlocking(s,~hundred,destination:~together);
FluidBufCompose.processBlocking(s,~threshed,destination:~together,destStartChan:1);
)

// plot it
FluidWaveform(featuresBuffer:~together,bounds:Rect(0,0,1600,400),lineWidth:2,normalizeFeaturesIndependently:false);

::
