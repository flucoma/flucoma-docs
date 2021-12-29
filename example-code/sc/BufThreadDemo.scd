
For a thorough explanation, please refer to the tutorial on link::Guides/FluidBufMultiThreading::.

CODE::
// define a destination buffer
b=Buffer.alloc(s,1);

// a simple call, where we query the destination buffer upon completion with the action message.
FluidBufThreadDemo.process(s, b, 1000, action:{|x|x.get(0,{|y|y.postln});});

// as the 'process' returns its instance, we can cancel the process easily
c = FluidBufThreadDemo.process(s, b, 100000, action: {|x|x.get(0,{|y|y.postln});});
c.cancel;

// if a simple call to the UGen is used, the progress can be monitored. The usual cmd-period will cancel the job by freeing the synth.
{c = FluidBufThreadDemo.kr(b,10000).poll; FreeSelfWhenDone.kr(c)}.scope;
::
