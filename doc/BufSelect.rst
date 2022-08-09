:digest: Select and copy specific values from a buffer
:species: buffer-proc
:sc-categories: FluidCorpusManipulation
:sc-related: Classes/Buffer, Classes/BufRd, Classes/Index, Classes/IndexL
:see-also: BufSelectEvery
:max-seealso: poke~, peek~, index~, buffer~
:description: Copies sets of values from a buffer, described in terms of a list of frame indices and channel numbers.


:control source:

   The |buffer| to select values from

:control destination:

   The |buffer| to write the selected data to

:control indices:

   A 0-based list of frame numbers to copy. Default is [-1], meaning all frames

:control channels:

   A 0-based list of channel numbers to copy. Default is [-1], meaning all channels