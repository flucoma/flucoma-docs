s.boot;

// load a sound to slice
~drums = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

// display
FluidWaveform(~drums,bounds:Rect(0,0,1200,300));

// put in another window
(
w = Window("FluidWaveform Test",Rect(0,0,1000,600));
FluidWaveform(~drums,parent:w,bounds:Rect(100,100,800,300));
w.front;
)

// show spectrogram
~mags = Buffer(s);
FluidBufSTFT.processBlocking(s,~drums,magnitude:~mags);
FluidWaveform(~drums,bounds:Rect(0,0,1200,300),rasterBuffer:~mags,rasterColorScheme:1);

// show mels
~mels = Buffer(s);
FluidBufMelBands.processBlocking(s,~drums,features:~mels,numBands:512,windowSize:1024,action:{"done".postln});

~mels.postln;

FluidWaveform(~drums,bounds:Rect(0,0,1600,400),rasterBuffer:~mels,rasterColorScheme:1);

// spectrogram with some nice colors and a bit of styling...
FluidWaveform(~drums,bounds:Rect(0,0,1200,300),showSpectrogram:true,spectrogramColorScheme:1,waveformColor:Color.magenta(1,0.5),showWaveform:true);

// create a buffer to put indices into
~indices = Buffer(s);

// do a slice analysis
FluidBufAmpSlice.processBlocking(s,~drums,indices:~indices,fastRampUp: 10,fastRampDown: 2205,slowRampUp: 4410,slowRampDown: 4410,onThreshold: 10,offThreshold: 5,floor: -40,minSliceLength: 4410,highPassFreq: 20);

// plot the buffer with the indices overlayed
FluidWaveform(~drums,~indices,bounds:Rect(0,0,800,200));

// do a descriptor analysis
~features = Buffer(s);
FluidBufLoudness.processBlocking(s,~drums,features:~features,action:{"done".postln;});

// copy just the first channel of that buffer to display it
~features2 = Buffer(s);
FluidBufCompose.processBlocking(s,~features,numChans:1,destination:~features2);

// plot the audio with the slices and the loudness analysis
FluidWaveform(~drums,~indices,~features2,bounds:Rect(0,0,1200,300));

// with gate info
~gate_analysis = Buffer(s);
FluidBufAmpGate.processBlocking(s,~drums,indices:~gate_analysis,onThreshold:-35,offThreshold:-35,minSliceLength:4410);

// it will plot the ons and offs
FluidWaveform(~drums,~gate_analysis,~features2,bounds:Rect(0,0,1200,300));

// do a descriptor analysis and plot both features either stacked or not:
~noisy = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));
~pitch_analysis = Buffer(s);

FluidBufPitch.processBlocking(s,~noisy,features:~pitch_analysis,action:{"done".postln;});

// plot not stacked:
FluidWaveform(~noisy,featureBuffer:~pitch_analysis,bounds:Rect(0,0,1200,300));

// plot stacked:
FluidWaveform(~noisy,featureBuffer:~pitch_analysis,bounds:Rect(0,0,1200,300),stackFeatures:true,waveformColor:Color(*0.9.dup(3)));

// add spectrogram:
FluidWaveform(~noisy,featureBuffer:~pitch_analysis,bounds:Rect(0,0,1200,300),stackFeatures:true,waveformColor:Color(0,0,0,0.5),showSpectrogram:true,spectrogramAlpha:0.5);

// plot in another window with all the things!

(
w = Window("FluidWaveform Test",Rect(0,0,1000,600));
FluidWaveform(
	~noisy,
	featureBuffer:~pitch_analysis,
	parent:w,
	bounds:Rect(100,100,800,300),
	stackFeatures:true,
	showSpectrogram:true,
	spectrogramAlpha:0.6,
	waveformColor:Color(0,1,1,0.5)
);
w.front;
)
