code::

(
~ls = FluidLabelSet.new(s);
~ls.addLabel("perth","hot");
~ls.addLabel("huddersfield","cold");
~ls.print;
)

(
// set label will add if it doesn't exist
~ls.setLabel("chicago","cold");
// or update if it does
~ls.setLabel("huddersfield","hot");
~ls.print;
)

(
// update label will update an existing label
~ls.updateLabel("perth","dry-heat");
~ls.updateLabel("huddersfield","wet-winter");
~ls.updateLabel("chicago","polar-vortex");
~ls.print;
)

// delete label will, ahem, delete a label
(
~ls.deleteLabel("huddersfield");
~ls.print;
)

(
// dump gives a dictionary
~ls.dump({
	arg dict;
	dict.keysValuesDo{
		arg k, v;
		"%:\t%".format(k,v).postln;
	};
});
)
::
strong::Labeling Audio Analyses::
code::

(
~src = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));
~ds = FluidDataSet(s);
~ls = FluidLabelSet(s);
)

// find the average mfcc values across this sound file and add to the dataset
// at the same time, add a label to the label set with the same identifier
(
var id = "ASWINE";
var mfccs = Buffer(s);
var stats = Buffer(s);
var flat = Buffer(s);
~ls.addLabel(id,"noisy");
FluidBufMFCC.processBlocking(s,~src,features:mfccs,startCoeff:1);
FluidBufStats.processBlocking(s,mfccs,stats:stats,select:[\mean]);
FluidBufFlatten.processBlocking(s,stats,destination:flat);
~ds.addPoint(id,flat);
~ds.print;
~ls.print;
)

::
strong::Other Messages::
code::

// do some analyses and get them all to a label set and data set
(
~srcA = Buffer.read(s,FluidFilesPath("Tremblay-AaS-SynthTwoVoices-M.wav"));
~srcB = Buffer.readChannel(s,FluidFilesPath("Tremblay-CF-ChurchBells.wav"),channels:[0]);
)

(
fork{
	var labels = ["synth","bells"];
	var mfccs = Buffer(s);
	var flat = Buffer(s);
	var counter = 0;

	~ds = FluidDataSet(s);
	~ls = FluidLabelSet(s);

	[~srcA,~srcB].do{
		arg buf, i;
		FluidBufMFCC.processBlocking(s,buf,features:mfccs,startCoeff:1);
		s.sync;
		mfccs.numFrames.do{
			arg frame;
			var id = "mfcc-analysis-%".format(counter.asInteger);
			FluidBufFlatten.processBlocking(s,mfccs,frame,1,destination:flat);
			~ds.addPoint(id,flat);
			~ls.addLabel(id,labels[i]);
			counter = counter + 1;
		};
	};

	~ds.print;
	~ls.print;
}
)

// save to disk
~ls.write(Platform.defaultTempDir+/+"mfcc-analysis-labels.json");

// read from disk
FluidLabelSet(s).read(Platform.defaultTempDir+/+"mfcc-analysis-labels.json").print;

// how many lables are there
~ls.size

// clear
(
~ls.clear;
~ls.print;
)
::
link::Classes/Dictionary:: strong::interface::
code::

(
FluidLabelSet(s).load(
	Dictionary.newFrom([
		"cols",1,
		"data",Dictionary.newFrom([
			"violin","string",
			"viola","string",
			"trumpet","brass",
			"trombone","brass",
			"clarinet","wind"
		])
	])
).print;
)

::

link::Merging::
code::

a = Dictionary.newFrom([\cols, 1, \data, Dictionary.newFrom([\one, \un,\two,\deux])]);
b = FluidLabelSet(s)
b.load(a)
b.print

a = Dictionary.newFrom([\cols, 1, \data, Dictionary.newFrom([\three, \trois, \two,\zwei])]);
c = FluidLabelSet(s)
c.load(a)
c.print

b.merge(c)
b.print //common items not replaced

b.merge(c,1)
b.print //now they are

::