(
SCDoc.indexAllDocuments(true);

SCDoc.renderAll(true);
)

// really wish i could get something like this to work:
(
SCDoc.indexAllDocuments(true);
f = SCDoc.helpSourceDirs.select({arg p; /*p.postln;*/ p.contains("flucoma")})[0];
[PathName(f+/+"Classes").files[1]].do{
	arg pn;
	var node, entry;
	"\n\n\n\nfilename: %".format(pn.fileName).postln;
	"full path: %".format(pn.fullPath).postln;
	node = SCDoc.parseFileFull(pn.fullPath);
	"node: %".format(node).postln;
	entry = SCDocEntry(node,"Classes/%".format(pn.fileNameWithoutExtension));
	entry.postln;
	SCDoc.parseAndRender(entry);
	// SCDoc.parseFileFull(node);
};
)

// for checking some individual files:
FluidNormalize

FluidBufHPSS

FluidDataSet

FluidStats

(
{
	var sig = SinOsc.kr * 0.1;
	sig = FluidStats.kr(sig,3);
	sig.poll;
}.play;
)