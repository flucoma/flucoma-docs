
code::
(
~classifier=FluidMLPClassifier(s).hidden_([6]).activation_(FluidMLPClassifier.tanh).maxIter_(1000).learnRate_(0.1).momentum_(0.1).batchSize_(50).validation_(0);
~sourcedata= FluidDataSet(s);
~labels = FluidLabelSet(s);
~testdata = FluidDataSet(s);
~predictedlabels = FluidLabelSet(s);
)
//Make some clumped 2D points and place into a DataSet
(
~centroids = [[0.5,0.5],[-0.5,0.5],[0.5,-0.5],[-0.5,-0.5]];
~categories = [\red,\orange,\green,\blue];
~trainingset = Dictionary();
~labeldata = Dictionary();
4.do{ |i|
	64.do{ |j|
		~trainingset.put("mlpclass"++i++\_++j, ~centroids[i].collect{|x| x.gauss(0.5/3)});
		~labeldata.put("mlpclass"++i++\_++j,[~categories[i]]);
	}
};
~sourcedata.load(Dictionary.with(*[\cols->2,\data->~trainingset]),action:{~sourcedata.print});
~labels.load(Dictionary.with(*[\cols->1,\data->~labeldata]),action:{~labels.print});
)

//Fit the classifier to the example DataSet and labels, and then run prediction on the test data into our mapping label set
~classifier.fit(~sourcedata,~labels,action:{|loss| ("Trained"+loss).postln});

//make some test data
(
~testset = Dictionary();
4.do{ |i|
	64.do{ |j|
		~testset.put("mlpclass_test"++i++\_++j, ~centroids[i].collect{|x| x.gauss(0.5/3)});
	}
};
~testdata.load(Dictionary.with(*[\cols->2,\data->~testset]),action:{~testdata.print});
)

//Run the test data through the network, into the predicted labelset
~classifier.predict(~testdata,~predictedlabels,action:{"Test complete".postln});

//get labels from server
~predictedlabels.dump(action:{|d| ~labelsdict = d["data"]; ~labelsdict.postln});

//Visualise: we're hoping to see colours neatly mapped to quandrants...
(
c = Dictionary();
c.add("red"->Color.red);
c.add("blue"->Color.blue);
c.add("green"->Color.green);
c.add("orange"->Color.new255(255, 127, 0));
e = 200 * ((~centroids + 1) * 0.5).flatten(1).unlace;
w = Window("scatter", Rect(128, 64, 200, 200));
w.drawFunc = {
    Pen.use {
		~testset.keysValuesDo{|k,v|
			var x = v[0].linlin(-1,1,200,0).asInteger;
			var y = v[1].linlin(-1,1,200,0).asInteger;
			var r = Rect(x,y,5,5);
			Pen.fillColor = c.at(~labelsdict[k][0]);
			Pen.fillOval(r);
		}
    }
};
w.refresh;
w.front;
)

// single point transform on arbitrary value
~inbuf = Buffer.loadCollection(s,0.5.dup);
~classifier.predictPoint(~inbuf,{|x|x.postln;});
::
subsection::Querying in a Synth
This is the equivalent of code::predictPoint::, but wholly on the server
code::
(
{
	var trig = Impulse.kr(5);
	var point = WhiteNoise.kr(1.dup);
    var inputPoint = LocalBuf(2);
    var outputPoint = LocalBuf(1);
	Poll.kr(trig, point, [\pointX,\pointY]);
	point.collect{ |p,i| BufWr.kr([p],inputPoint,i)};
    ~classifier.kr(trig,inputPoint,outputPoint);
    Poll.kr(trig,BufRd.kr(1,outputPoint,0,interpolation:0),\cluster);
    Silent.ar;
}.play;
)

// to sonify the output, here are random values alternating quadrant.
(
{
	var trig = Impulse.kr(MouseX.kr(0,1).exprange(0.5,ControlRate.ir /2).poll(trig: 2,label: "Query Frequency"));
	var step = Stepper.kr(trig,max:3);
	var point = TRand.kr(-0.1, [0.1, 0.1], trig) + [step.mod(2).linlin(0,1,-0.6,0.6),step.div(2).linlin(0,1,-0.6,0.6)] ;
    var inputPoint = LocalBuf(2);
    var outputPoint = LocalBuf(1);
	point.collect{|p,i| BufWr.kr([p],inputPoint,i)};
    ~classifier.kr(trig,inputPoint,outputPoint);
    SinOsc.ar((BufRd.kr(1,outputPoint,0,interpolation:0) + 69).midicps,mul: 0.1)
}.play;
)
::
