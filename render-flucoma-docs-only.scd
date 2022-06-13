(
// render all flucoma docs:
fork({
	SCDoc.indexAllDocuments(true);
	0.1.wait;
	PathName(Platform.userExtensionDir+/+"FluidCorpusManipulation/HelpSource/Classes/").filesDo{
		arg pn;
		var name = pn.fileNameWithoutExtension;
		name.postln;
		try{
			name.interpret.openHelpFile;
		};
		0.2.wait;
	};
},AppClock);
)

// for testing individual docs later:
SCDoc.indexAllDocuments(true);

