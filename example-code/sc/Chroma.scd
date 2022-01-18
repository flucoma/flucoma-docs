
code::
//create a monitoring bus for the descriptors
b = Bus.new(\control,0,24);

//create a monitoring window for the values

(
w = Window("Chroma Bins Monitor", Rect(10, 10, 620, 320)).front;
a = MultiSliderView(w,Rect(10, 10, 600, 300)).elasticMode_(1).isFilled_(1);
)

//run the window updating routine.
(
~winRange = 0.1;
r = Routine {
    {
        b.get({ arg val;
            {
                if(w.isClosed.not) {
                    a.value = val/~winRange;
                }
            }.defer
        });
        0.01.wait;
    }.loop
}.play
)

//play a simple sound to observe the values
(
x = 	{
	var source = SinOsc.ar(LFTri.kr(0.1).exprange(80,800),0,0.1);
	Out.kr(b,FluidChroma.kr(source, numChroma: 24, maxNumChroma:24));
	source.dup;
}.play;
)

//we can observe that in the low end, the precision of the fft is not good enough to give a sharp pitch centre. We still can observe the octaviation quantized in quarter tones.

// free this source
x.free

// load a more exciting one
c = Buffer.read(s,File.realpath(FluidChroma.class.filenameSymbol).dirname.withTrailingSlash ++ "../AudioFiles/Tremblay-SlideChoirAdd-M.wav");

// analyse with parameters to be changed
(
x = 	{arg chroma = 24, low = 20, high = 20000, norm=1, t_cue, sel=0;
	var source = Select.ar(sel, [
		PlayBuf.ar(1,c,loop:1),
		Saw.ar(TIRand.kr(60.dup(3),96,t_cue).poll(t_cue).midicps,0.05).sum;
	]);
	Out.kr(b,FluidChroma.kr(source ,numChroma: chroma, minFreq: low, maxFreq: high, normalize: norm, maxNumChroma: 24, windowSize: 4096) / 10);
	source.dup;
}.play;
)

//set the winRange to a more informative value
~winRange = 0.03;

//instead, let's normalise each frame independently
~winRange = 0.12;
x.set(\norm, 2);

// observe the number of chroma. The unused ones at the top are not updated
x.set(\chroma,12)

// back to the full range
x.set(\chroma,24)

// change the source to random three-note chords
x.set(\sel, 1)

// trigger new chords and observe the chroma contour
x.set(\t_cue, 1)

// focus all the chroma bin on a low mid range (there might be nothing!)
x.set(\low,320, \high, 800)

// or on a specific octave
x.set(\low, 60.midicps, \high, 72.midicps)

// back to full range
x.set(\low,20, \high, 20000)

// free everything
x.free;b.free;c.free;r.stop;
::

STRONG::A musical example::

CODE::
//something will happen here.
::
