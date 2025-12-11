code::

b = Bus.audio(s);

(
c = {var input = In.ar(b);
	var sines = FluidSineFeature.kr(input,5);
	var voices = FluidVoiceAllocator.kr(sines[0], sines[1], 6);
	SendReply.kr(Impulse.kr(1),"/sourcesines", [sines ++ voices].flat);
	input.dup;
}.play;
)

(
o = OSCFunc({
    arg msg;
	"freqI + magI ".post; msg[3..12].round(0.01).postln;
	"freqO + magO ".post; msg[13..24].round(0.01).postln;
	"voice states ".post; msg[25..].round(1).postln;
},"/sourcesines");
)

// observe the voices as you add sines...
d = {Out.ar(b,SinOsc.ar(440,mul: 0.1))}.play
e = {Out.ar(b,SinOsc.ar(550,mul: 0.05))}.play
f = {Out.ar(b,SinOsc.ar(330,mul: 0.1))}.play
g = {Out.ar(b,SinOsc.ar(220,mul: 0.15))}.play
h = {Out.ar(b,SinOsc.ar(110,mul: 0.2))}.play

// or remove them
e.free
d.free
g.free

// add 6 sines too quiet too high so should not voice steal the looudest lowst 2 remaining

i = {Out.ar(b,SinOsc.ar(700.series(750,950),mul: 0.02).sum)}.play
i.free

::