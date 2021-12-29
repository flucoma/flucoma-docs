
code::

//Make a simple mapping between a ramp and a sine cycle, test with an exponentional ramp
(
~source = FluidDataSet(s);
~target = FluidDataSet(s);
~test = FluidDataSet(s);
~output = FluidDataSet(s);
~tmpbuf = Buffer.alloc(s,1);
~regressor = FluidKNNRegressor(s);
)

//Make source, target and test data
(
~sourcedata = 128.collect{|i|i/128};
~targetdata = 128.collect{|i| sin(2*pi*i/128) };
~testdata = 128.collect{|i|(i/128)**2};

~source.load(
	Dictionary.with(
        *[\cols -> 1,\data -> Dictionary.newFrom(
			~sourcedata.collect{|x, i| [i.asString, [x]]}.flatten)])
);

~target.load(
d = Dictionary.with(
        *[\cols -> 1,\data -> Dictionary.newFrom(
			~targetdata.collect{|x, i| [i.asString, [x]]}.flatten)]);
);

~test.load(
	Dictionary.with(
        *[\cols -> 1,\data -> Dictionary.newFrom(
			~testdata.collect{|x, i| [i.asString, [x]]}.flatten)])
);

~targetdata.plot;
~source.print;
~target.print;
~test.print;

)

// Now make a regressor and fit it to the source and target, and predict against test
//grab the output data whilst we're at it, so we can inspect
(
~outputdata = Array(128);
~regressor.fit(~source, ~target);
~regressor.predict(~test, ~output, 1, action:{
		~output.dump{|x| 128.do{|i|
		~outputdata.add(x["data"][i.asString][0])
	}};
});
)

//We should see a single cycle of a chirp
~outputdata.plot;

// single point transform on arbitrary value
~inbuf = Buffer.loadCollection(s,[0.5]);
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
