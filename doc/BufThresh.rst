:digest: A Gate Processor for Buffers
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit, Guides/FluidBufMultiThreading
:see-also: BufCompose, Gain, Stats
:description: 
   Replace all values under a threshold by 0.

:control source:

   The buffer to process containing the values to compare against the threshold.

:control startFrame:

   The starting point (in samples) from which to process the ``source``.

:control numFrames:

   The duration (in samples) to process in the ``source``. The default (-1) indicates to process through the end of ``source``.

:control startChan:

   The channel from which to begin the process in the ``source``.

:control numChans:

   The number of channels to process in ``source``. The default of -1 indicates to process through the last channel in ``source``.

:control destination:

   The buffer to write the processed data into.

:control threshold:

   Any values in ``source`` below this threshold will be written as 0 in ``destination``.
