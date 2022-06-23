:digest: A Tutorial Object to Experiment with Multithreading in FluidBuf* Objects
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Guides/FluidBufMultiThreading
:see-also: 
:description: 
   Implements a tutorial object to illustrate and experiment with the behaviour of the FluidBuf* objects. To simulate their behaviour in various blocking modes, the object after waiting for **time** milliseconds, return its delay length as a float writen at index [0] of the specified destination buffer.

:process: 
   This is the method that calls for the job to be done. In this case, simply waiting **time** milliseconds before writing a value in the destination buffer.


:control result:
   The destination buffer, where the value should be written at the end of the process.

:control time:
   The duration in milliseconds of the delay that the background thread will wait for before yielding the value to the destination buffer.

