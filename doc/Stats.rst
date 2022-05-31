:digest: Rolling mean and standard deviation on control inputs
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufStats, Standardize
:description: Computes the rolling mean and sample standard deviation over a given window for multichannel control inputs.
:discussion: 

  Each element of the list is dealt with in parallel. This is particularly suitable for multidimensional descriptors.

  .. only_in:: sc

     The parameter ``size`` is the number of previous control rate frames FluidStats will store and use to compute the statistics

:output: The [means] and [standard deviations] for each element of the original.


:control size:

   The size of the history window to use.
   
:message list:

   The input list to be processed
