:digest: Rolling mean and standard deviation on list inputs
:species: descriptor
:sc-categories: Libraries>FluidDecomposition
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufStats, Standardize
:description: Computes the rolling mean and sample standard deviation over a given window for multichannel list inputs.
:discussion: Each element of the list is dealt with in parallel. This is particularly suitable for multidimensional descriptors.
:output: The first outlet gives the [means], the second the [standard deviations], for each element of the original list.


:control size:

   The size of the history window to use.


:message list:

   The input list to be processed
