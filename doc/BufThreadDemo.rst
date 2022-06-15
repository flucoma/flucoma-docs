:digest: A Tutorial Object to Experiment with Multithreading in FluidBuf* Objects
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulation, Guides/FluidBufMultiThreading
:see-also: 
:description: 
   This class implements a simple tutorial object to illustrate and experiment with the behaviour of the FluidBuf* objects. It simply starts a process that will, upon completion of its task, write a single value to the destination buffer. This is the general behaviour of much of the CPU consuming FluidBuf* objects. In this case, as a toy example, the task is simply just wait and do nothing, to simulate a task that would actually take that long in the background.

   The process will, after waiting for **time** milliseconds, return its delay length as a Float writen at index [0] of the specified destination buffer.

:process: This is the method that calls for the job to be done. In this case, simply waiting **time** milliseconds before writing a value in the destination buffer.


:control result:

   The destination buffer, where the value should be written at the end of the process.

:control time:

   The duration in milliseconds of the delay that the background thread will wait for before yielding the value to the destination buffer.

