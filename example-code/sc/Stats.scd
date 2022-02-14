
code::
(
~gaussianNoise = { |a,b|
    var mag = (-2 * a.abs.log).sqrt;
    var f = 2 * pi * b.abs;
    [mag * f.cos, mag * f.sin]
}



{
    var src = ~gaussianNoise.value(WhiteNoise.kr,WhiteNoise.kr);
    var stats = FluidStats.kr(src,20);
    stats[0].poll(label:'means');
    stats[1].poll(label:'standard deviations');
}.play
)
::
