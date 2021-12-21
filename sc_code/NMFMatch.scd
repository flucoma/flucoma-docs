// FluidNMFMatch can be trained on a small section of audio and then used to identify whenever similar audio
// appears again in the whole file or other files

// for example, take this 22 second field recording that has _some_ dog barking in it
~golcar = Buffer.readChannel(s,FluidFilesPath("Tremblay-BaB-SoundscapeGolcarWithDog.wav"),channels:[0]);

~golcar.play;

// we'll do a FluidBufNMF analysis on just the first 4 seconds (the part that has some dog bark in it);
~bases = Buffer(s);
FluidBufNMF.processBlocking(s,~golcar,numFrames:~golcar.sampleRate * 4,bases:~bases,components:2,action:{"done".postln;});

// and then play the whole 22 second sound file through FluidNMFMatch to see where in the sound file the spectral template
// of the dog bark is found. because the FluidBufNMF analysis starts from a stochastic state, we can't be sure which base
// contains the dog bark, but watching the green bars in this window will make very clear which one is detecting where
// in the sound file a dog bark is found
(
Task({
	var match = [0,0]; // an array for storing the output of FluidNMFMatch
	var win = Window("FluidNMFMatch",Rect(0,0,200,400));
	var uv = UserView(win,win.bounds)
	.drawFunc_{
		var w = uv.bounds.width / 2;
		Pen.color_(Color.green);
		match.do{ // iterate over the two values in the match array that are taken from FluidNMFMatch
			arg match_val, i;
			var match_norm = match_val.linlin(0,30,0,uv.bounds.height); // make it a height appropriate for the window
			var top = uv.bounds.height - match_norm; // offset from the top so it looks like it's a bar rising from the bottom
			/*top.postln;*/
			Pen.addRect(Rect(i * w,top,w,match_norm)); // draw the rect
			Pen.draw;
		};
	};

	{
		var sig = PlayBuf.ar(1,~golcar,BufRateScale.ir(~golcar),doneAction:2); // play the whole sound file

		// 30 times per second send the output of FluidNMFMatch to the language
		SendReply.kr(Impulse.kr(30),"/nmfmatch",FluidNMFMatch.kr(sig,~bases,2));
		sig;
	}.play;

	OSCdef(\nmfmatch,{ // catch the output of FluidNMFMatch in the language
		arg msg;
		match = msg[3..]; // populate the array that is used for plotting
		{uv.refresh}.defer; // and then refresh the window
	},"/nmfmatch");

	win.front;

},AppClock).play;
)