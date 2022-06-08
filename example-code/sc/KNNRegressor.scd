
code::

// Making an input dataset of a ramp from 0-1 and an output dataset of a sine wave
// we'll have the KNNRegressor learn the relationship between the inputs and outputs
// so that any input value provided will return where on the sine wave (what amplitude)
// the output should be
(
~size = 128;
~ds_ramp = FluidDataSet(s).load(
	Dictionary.newFrom([
		\cols,1,
		\data,Dictionary.newFrom(
			~size.collect{arg i;
				[i,i/~size]; // linear: 128 steps from 0 to (slightly less than) 1
			}.flat
		)
	])
);

~ds_sine = FluidDataSet(s).load(
	Dictionary.newFrom([
		\cols,1,
		\data,Dictionary.newFrom(
			~size.collect{
				arg i;
				[i,sin(2pi*i/~size)]; // sine wave
			}.flat;
		)
	])
);
)

// fit to make the KNNRegressor learn the relationship between inputs and outputs
(
~regressor = FluidKNNRegressor(s).fit(~ds_ramp,~ds_sine);
)

// predicting with input dataset should give us what we expect: something that
// looks like a sine wave.
(
~predictions = FluidDataSet(s);
~regressor.predict(~ds_ramp,~predictions,{
	~predictions.dump({
		arg dict;
		var array = Array.newClear(~size);
		dict["data"].keysValuesDo{
			arg id, v;
			array[id.asInteger] = v[0];
		};
		{array.plot}.defer;
	});
});
)

// now instead of using the linear ramp to derive the output, we'll use a warped ramp: an exponetial curve
// make that dataset to use as input:
(
~ds_exponential = FluidDataSet(s).load(
	Dictionary.newFrom([
		\cols,1,
		\data,Dictionary.newFrom(
			~size.collect{arg i;
				[i,(i/~size)**2];
			}.flat;
		)
	])
);
)

// use the regressor to make predictions based on that input:
(
~regressor.predict(~ds_exponential,~predictions,{
	~predictions.dump({
		arg dict;
		var array = Array.newClear(~size);
		dict["data"].keysValuesDo{
			arg id, v;
			array[id.asInteger] = v[0];
		};
		array.postln;
		{array.plot}.defer;
	});
});
)

// just for fun let's use the sine wave ds as input...
// notice that all the negative values of the sine wave
// (the second half) are going to have the same three nearest
// neighbours and therefore the same value for their prediction!
(
~regressor.predict(~ds_sine,~predictions,{
	~predictions.dump({
		arg dict;
		var array = Array.newClear(~size);
		dict["data"].keysValuesDo{
			arg id, v;
			array[id.asInteger] = v[0];
		};
		array.postln;
		{array.plot}.defer;
	});
});
)

::
strong::single point transform on arbitrary value::
code::
~inbuf = Buffer.loadCollection(s,[0.3]);

~regressor.predictPoint(~inbuf,{|x|x.postln;});
::

subsection:: Server Side Queries

code::
//we are here querying with a saw in control rate, all on the server, via a buffer interface
(
{
	var input = Saw.kr(2).linlin(-1,1,0,1);
	var trig = Impulse.kr(ControlRate.ir/10);
	var inputPoint = LocalBuf(1);
	var outputPoint = LocalBuf(1);
	BufWr.kr(input,inputPoint,0);
	~regressor.kr(trig,inputPoint,outputPoint);
	BufRd.kr(1,outputPoint,0);
}.scope
)

::
