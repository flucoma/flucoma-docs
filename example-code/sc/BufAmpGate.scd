CODE::
~src = Buffer.read(s,FluidFilesPath("Constanzo-PreparedSnare-M.wav"));

// detect gates and post some info
(
~indices = Buffer(s);
FluidBufAmpGate.processBlocking(s,~src,indices:~indices,rampUp:110,rampDown:2205,onThreshold:-40, offThreshold:-41,minSilenceLength:1100,lookBack:441);
~indices.loadToFloatArray(action:{
	arg fa;
	var events = (fa.size / 2).asInteger;
	var avg = fa.clump(2).collect{arg arr; arr[1] - arr[0]}.mean / ~src.sampleRate;
	"found % gate events averaging % seconds".format(events,avg).postln;
});
)

//loops over a gate event from onset to offset using MouseX to choose which gate event
(
{
	var gate_index = MouseX.kr(0,~indices.numFrames).poll(label:"gate index");
	var start, end, phs;
	# start, end = BufRd.kr(2,~indices,gate_index,1,1);
	phs = Phasor.ar(0,BufRateScale.ir(~src),start,end);
	BufRd.ar(1,~src,phs,1,4).dup;
}.play;
)
::
strong::Visualize it with FluidWaveform::
code::

~src = Buffer.read(s,FluidFilesPath("Constanzo-PreparedSnare-M.wav"));
(
~indices = Buffer(s);
FluidBufAmpGate.processBlocking(s,~src,indices:~indices,rampUp:110,rampDown:2205,onThreshold:-40, offThreshold:-41,minSilenceLength:1100,lookBack:441);
FluidWaveform(~src,~indices,bounds:Rect(0,0,1600,400));
)

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));
(
~indices = Buffer(s);
FluidBufAmpGate.processBlocking(s,~src,indices:~indices,rampUp:110,rampDown:441,onThreshold:-20, offThreshold:-24,minSilenceLength:441,lookBack:441);
FluidWaveform(~src,~indices,bounds:Rect(0,0,1600,400));
)

::
strong::Remove silence from a buffer::
code::

~src = Buffer.read(s,FluidFilesPath("Olencki-TenTromboneLongTones-M.wav"));

(
var concat_buf = Buffer(s);
var indices = Buffer(s);
var display_buffer = Buffer(s);
FluidBufCompose.processBlocking(s,~src,destination:display_buffer);
FluidBufAmpGate.processBlocking(s,display_buffer,indices:indices,onThreshold:-30,offThreshold:-40,minSliceLength:0.1*s.sampleRate,minSilenceLength:0.1*s.sampleRate,rampDown:0.01*s.sampleRate);
indices.loadToFloatArray(action:{
	arg fa;
	var current_frame = 0;

	// this array is initally flat, but is alternating [ onset0 , offset0 , onset1 , offset1 , onset2 ... ],
	// so by using .clump(2) we clump each onset and offest together to get an array like this:
	// [ [ onset0 , offset0 ] , [ onset1 , offset1 ] , [ onset2 , offset2 ] , ... ]
	fa = fa.clump(2);

	fa.do{
		arg arr, i;
		var startFrame = arr[0];
		var numFrames = arr[1] - startFrame;
		"%\tstart: %\tend: %".format(i,startFrame,numFrames).postln;
		FluidBufCompose.processBlocking(s,display_buffer,startFrame,numFrames,destination:concat_buf,destStartFrame:current_frame);
		current_frame = current_frame + numFrames;
	};

	FluidBufCompose.processBlocking(s,concat_buf,destination:display_buffer,destStartChan:1);

	s.sync;

	{
		var win = Window(bounds:Rect(0,0,1600,400));
		FluidWaveform(display_buffer,parent:win,bounds:win.bounds,standalone:false);
		UserView(win,win.bounds)
		.drawFunc_{
			["original","with silence removed"].do{
				arg txt, i;
				var y_ = (win.bounds.height * 0.5 * i) + (win.bounds.height * 0.1);
				Pen.stringAtPoint(txt,Point(10,y_),color:Color.red);
			};
		};
		win.front;
		display_buffer.play;
	}.defer;
});
)
::
strong::Visualizing Parameters::
code::

~drum_hit = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"),350854,21023);

// we'll try to tweak some parameters to slice out this drum hit just how we want
(
~drum_hit.play;
FluidWaveform(~drum_hit);
)

// just putting in some thresholds probably won't provide what we're looking for
(
~indices = Buffer(s);
FluidBufAmpGate.processBlocking(s,~drum_hit,indices:~indices,onThreshold:-20,offThreshold:-20);
FluidWaveform(~drum_hit,~indices);
)

// adjusting the ramp times (units are in samples) will help smooth out the envelope follower
(
~indices = Buffer(s);
FluidBufAmpGate.processBlocking(s,~drum_hit,indices:~indices,rampUp:441,rampDown:4410,onThreshold:-20,offThreshold:-20);
FluidWaveform(~drum_hit,~indices);
)

::
strong::Basic Tests::
code::

(
b = Buffer.sendCollection(s, Array.fill(44100,{|i| sin(i*pi/ (44100/640)) * (sin(i*pi/ 22050)).abs}));
c = Buffer.new(s);
)

//basic tests: threshold sanity
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//basic tests: threshold hysteresis
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -16)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//basic tests: threshold min slice
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minSliceLength:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//basic tests: threshold min silence
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minSilenceLength:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//mid tests: threshold time hysteresis on
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minLengthAbove:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//mid tests: threshold time hysteresis off
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, minLengthBelow:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//mid tests: threshold with lookBack
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, lookBack:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//mid tests: threshold with lookAhead
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, lookAhead:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})

//mid tests: threshold with asymetrical lookBack and lookAhead
FluidBufAmpGate.process(s, b, indices:c, rampUp:5, rampDown:25, onThreshold:-12, offThreshold: -12, lookBack:221, lookAhead:441)
c.query
c.getn(0,c.numFrames*2,{|item|item.postln;})
::