code::
s.boot;

// 10 random points and their square
~somepoints = 10.collect{var x = 1.0.rand; [x, x**2]}.flop

// load the ins and the outs in 1D datasets
~in = FluidDataSet(s).load(Dictionary.newFrom(["cols", 1, "data", Dictionary.newFrom(~somepoints[0].collect{|j,i|[i.asSymbol, j]}.flat)]))

~out = FluidDataSet(s).load(Dictionary.newFrom(["cols", 1, "data", Dictionary.newFrom(~somepoints[1].collect{|j,i|[i.asSymbol, j]}.flat)]))

~in.print;~out.print

~polyreg = FluidPolynomialRegressor(s);

~polyreg.fit(~in, ~out, {\done.postln});

// 100 points to draw the function

~question = FluidDataSet(s).load(Dictionary.newFrom(["cols", 1, "data", Dictionary.newFrom(100.collect{|i|[i,i/100]}.flat)]))
~answer = FluidDataSet(s)

~polyreg.predict(~question, ~answer, {\done.postln});

~arrayedanswer = Array.fill(100,0)
~answer.dump{|x|x["data"].keysValuesDo{|k,v|~arrayedanswer[k.asInteger]=v}}
~arrayedanswer.flat.plot

//compare with the real function
100.collect{|x|(x/100)**2}.plot
::