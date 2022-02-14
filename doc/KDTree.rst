:digest: Efficient lookup of data using a k-d tree.
:species: data
:sc-categories: FluidManipulation
:sc-related: Classes/FluidDataSet
:see-also: DataSet
:description: A k-dimensional tree for efficient neighbourhood searches of multi-dimensional data.
:discussion: 
   :fluid-obj:`KDTree` facilitates efficient nearest neighbour searches of multi-dimensional data stored in a :fluid-obj:`DataSet`. 

   Whilst k-d trees can offer very good performance relative to naïve search algorithms, they suffer from something called “the curse of dimensionality” (like many algorithms for multi-dimensional data). In practice, this means that as the number of dimensions of your data goes up, the relative performance gains of a k-d tree go down.

   For more information see https://learn.flucoma.org/reference/kdtree.



:control numNeighbours:

   The number of neighbours to return.

:control dataSet:

   An optional :fluid-obj:`DataSet` from which data points will be returned for realtime queries. This does not need to be the same DataSet that the tree was fitted against, but does need to have matching labels. Using this mechanism, we have a way to, e.g. associate labels with segments of playback buffers, without needing pass strings around.


:message fit:

   :arg dataSet: The :fluid-obj:`DataSet` of interest. This can either be a data set object itself, or the name of one.

   :arg action: A function to run when indexing is complete.

   Build the tree by scanning the points of a :fluid-obj:`DataSet`

:message kNearest:

   :arg buffer: A |buffer| containing a data point to match against. The number of frames in the buffer must match the dimensionality of the :fluid-obj:`DataSet` the tree was fitted to.

   :arg action: A function that will run when the query returns, whose argument is an array of point identifiers from the tree's :fluid-obj:`DataSet`. The returned identifiers are always type symbol, therefore would need to be converted to a number type if intended to be used in that way.

   Returns the identifiers of the ``k`` points nearest to the one passed.

:message kNearestDist:

   :arg buffer: A |buffer| containing a data point to match against. The number of frames in the buffer must match the dimensionality of the :fluid-obj:`DataSet` the tree was fitted to.

   :arg action: A function that will run when the query returns, whose argument is an array of distances.

   Get the distances of the K nearest neighbours to a point.
