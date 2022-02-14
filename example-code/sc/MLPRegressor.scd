
code::

//Make a simple mapping between a ramp and a sine cycle, test with an exponentional ramp
(
~source = FluidDataSet(s);
~target = FluidDataSet(s);
~test = FluidDataSet(s);
~output = FluidDataSet(s);
~tmpbuf = Buffer.alloc(s,1);
~regressor=FluidMLPRegressor(s).hidden_([2]).activation_(FluidMLPRegressor.tanh).outputActivation_(FluidMLPRegressor.tanh).maxIter_(1000).learnRate_(0.1).momentum_(0.1).batchSize_(1).validation_(0);
)

//Make source, target and test data
(
~sourcedata = 128.collect{|i|i/128};
~targetdata = 128.collect{|i| sin(2*pi*i/128) };
~testdata = 128.collect{|i|(i/128)**2};

~source.load(
    Dictionary.with(
        *[\cols -> 1,\data -> Dictionary.newFrom(
            ~sourcedata.collect{|x, i| [i.asString, [x]]}.flatten)]);
);

~target.load(
d = Dictionary.with(
        *[\cols -> 1,\data -> Dictionary.newFrom(
            ~targetdata.collect{|x, i| [i.asString, [x]]}.flatten)]);
);

~test.load(
    Dictionary.with(
        *[\cols -> 1,\data -> Dictionary.newFrom(
            ~testdata.collect{|x, i| [i.asString, [x]]}.flatten)]);
);

~targetdata.plot;
~source.print;
~target.print;
~test.print;
)

// Now make a regressor and fit it to the source and target, and predict against test
//grab the output data whilst we're at it, so we can inspect

// run this to train the network for up to 1000(max epochs to map source to target. fit() returns loss. If this is -1, then training has failed. Run until the printed error is satisfactory to you
~regressor.fit(~source, ~target, {|x|x.postln;});

//you can change parameters of the MLPregressor with setters
~regressor.learnRate = 0.01;
~regressor.momentum = 0;
~regressor.validation= 0.2;

(
~outputdata = Array(128);
~regressor.predict(~test, ~output, action:{
    ~output.dump{|x| 128.do{|i|
        ~outputdata.add(x["data"][i.asString][0])
    }};
}
);
)

//We should see a single cycle of a chirp. If not, fit a little more epochs
~outputdata.plot;

// single point transform on arbitrary value
~inbuf = Buffer.loadCollection(s,[0.5]);
~outbuf = Buffer.new(s);
~regressor.predictPoint(~inbuf,~outbuf,{|x|x.postln;x.getn(0,1,{|y|y.postln;};)});
::

subsection:: Querying in a Synth

This is the equivalent of calling code::predictPoint::, except wholly on the server

code::
(
{
	var input = Saw.kr(2).linlin(-1,1,0,1);
	var trig = Impulse.kr(ControlRate.ir/10);
    var inputPoint = LocalBuf(1);
    var outputPoint = LocalBuf(1);
	BufWr.kr(input,inputPoint,0);
    ~regressor.kr(trig,inputPoint,outputPoint,0,-1);
    Poll.kr(trig,BufRd.kr(1,outputPoint,0),"mapped value");
}.scope;
)



::
