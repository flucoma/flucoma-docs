:digest: Select and copy specific values from a buffer
:species: buffer-proc
:sc-categories: FluidCorpusManipulation
:sc-related: Classes/Buffer
:see-also: BufSelectEvery
:description: Copies sets of values from a buffer, described in terms of a list of frame indices and channel numbers.


:control source:

   The |buffer| to select values from

:control destination:

   The |buffer| to write the selected data to

:control indices:

   A 0-based list of channel numbers to recover. Default is [-1], meaning all frames

