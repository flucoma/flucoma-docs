
For a thorough explanation, please refer to the tutorial on link::Guides/FluidBufMultiThreading::.
Using code::.process:: will spawn a new thread to do the processing.

CODE::
// define a destination buffer
b = Buffer.alloc(s,1);

// a simple call, where we query the destination buffer upon completion with the action message.
FluidBufThreadDemo.process(s, b, 1000, action:{|x|x.get(0,{|y|y.postln});});

// as the 'process' returns its instance, we can cancel the process easily
c = FluidBufThreadDemo.process(s, b, 100000, action: {|x|x.get(0,{|y|y.postln});});
c.cancel;

// if a simple call to the UGen is used, the progress can be monitored. The usual cmd-period will cancel the job by freeing the synth.
(
{
	c = FluidBufThreadDemo.kr(b,10000).poll;
	FreeSelfWhenDone.kr(c)
}.scope;
)
::
strong::processBlocking::

Using code::.processBlocking:: will add the process to the OCS server queue to ensure that the operations get done in order.
code::

b = Buffer.alloc(s,1);

(
FluidBufThreadDemo.processBlocking(s, b, 1000, action:{"job 1 done".postln});
FluidBufThreadDemo.processBlocking(s, b, 500, action:{"job 2 done".postln});
FluidBufThreadDemo.processBlocking(s, b, 1500, action:{"job 3 done".postln});
)

(
fork{
	FluidBufThreadDemo.processBlocking(s, b, 1000, action:{"job 1 done".postln});
	s.sync;
	FluidBufThreadDemo.processBlocking(s, b, 500, action:{"job 2 done".postln});
	s.sync;
	FluidBufThreadDemo.processBlocking(s, b, 1500, action:{"job 3 done".postln});
}
)
::