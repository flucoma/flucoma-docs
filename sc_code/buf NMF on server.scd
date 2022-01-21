(
Task{
	//var buf = Buffer.read(s,"/Users/macprocomputer/Desktop/cymbal+sax/cymbal excerpt.wav");
	// var buf = Buffer.read(s,"/Users/macprocomputer/Desktop/_flucoma/code/flucoma-core-src/AudioFiles/Tremblay-AaS-AcousticStrums-M.wav");
	var buf = Buffer.read(s,"/Users/macprocomputer/Desktop/_flucoma/code/flucoma-core-src/AudioFiles/Tremblay-AaS-VoiceQC-B2K-M.wav");
	//var buf = Buffer.read(s,"/Users/macprocomputer/Desktop/_flucoma/code/flucoma-core-src/AudioFiles/Tremblay-Iterative-M.wav");
	//var buf = Buffer.read(s,"/Users/macprocomputer/Desktop/_flucoma/code/flucoma-core-src/AudioFiles/Nicol-LoopE-M.wav");
	//var buf = Buffer.read(s,"/Users/macprocomputer/Desktop/_flucoma/code/flucoma-core-src/AudioFiles/Olencki-TenTromboneLongTones-M.wav");
	//var buf = Buffer.read(s,"/Users/macprocomputer/Desktop/_flucoma/code/flucoma-core-src/AudioFiles/Green-Box639.wav");
	var dur = 3;
	var n_components = 3;
	var resynth_buf0 = Buffer.alloc(s,s.sampleRate * dur * 0.5,n_components);
	var resynth_buf1 = Buffer.alloc(s,s.sampleRate * dur * 0.5,n_components);
	var actbuf = Buffer(s);
	var basbuf = Buffer(s);
	s.sync;

	// FluidBufNMF.process(s,buf,0,s.sampleRate,resynth:resynth_buf,components:2,action:{"done".postln;});

	s.sync;


	buf.postln;
	{
		var sig = PlayBuf.ar(1,buf,BufRateScale.ir(buf),loop:1);
		var circle_buf = LocalBuf(SampleRate.ir * dur);
		var phs = Phasor.ar(end:circle_buf.numFrames);
		var half = phs > (circle_buf.numFrames / 2);
		var phs0, phs1;
		var t0, t1, env0, env1, sig0, sig1;
		var wet;
		var att = 0.03, rel = 0.03;
		half.poll;

		BufWr.ar(sig,circle_buf,phs);

		t0 = FluidBufNMF.kr(circle_buf,0,circle_buf.numFrames / 2,bases:basbuf,activations:actbuf,resynth:resynth_buf0,components:n_components,trig:half);
		t1 = FluidBufNMF.kr(circle_buf,circle_buf.numFrames / 2,circle_buf.numFrames / 2,bases:basbuf,activations:actbuf,resynth:resynth_buf1,components:n_components,trig:1-half);

		phs0 = Phasor.ar(Done.kr(t0),1,0,circle_buf.numFrames);
		phs1 = Phasor.ar(Done.kr(t1),1,0,circle_buf.numFrames);

		env0 = EnvGen.kr(Env([0,1,1,0],[att,resynth_buf0.duration-(att+rel),rel]),Done.kr(t0));
		env1 = EnvGen.kr(Env([0,1,1,0],[att,resynth_buf1.duration-(att+rel),rel]),Done.kr(t1));

		sig0 = BufRd.ar(n_components,resynth_buf0,phs0,0,1) * env0;
		sig1 = BufRd.ar(n_components,resynth_buf1,phs1,0,1) * env1;

		wet = sig0 + sig1;
		wet = CombC.ar(wet,dur/2,[dur/2,(dur/2) - 0.1],2);
		(Splay.ar(wet) + Pan2.ar(sig));
		// wet
	}.play;

	// resynth_buf.plot;
}.play(AppClock);

OSCdef(\half,{
	"changed".postln;
},"/changed");
)