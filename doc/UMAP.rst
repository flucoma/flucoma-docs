:digest: Dimensionality Reduction with Uniform Manifold Approximation and Projection
:species: data
:sc-categories: Dimensionality Reduction, Data Processing
:sc-related: Classes/FluidMDS, Classes/FluidDataSet
:see-also: 
:description: Reduce the dimensions of a :fluid-obj:`DataSet` using the Uniform Manifold Approximation and Project (UMAP) algorithm.
:discussion: 
   Performs dimensionality reduction of a :fluid-obj:`DataSet` using Uniform Manifold Approximation and Projection (UMAP)

   Please refer to https://umap-learn.readthedocs.io/ and https://learn.flucoma.org/reference/umap for more information on the algorithm.



:control numDimensions:

   The number of dimensions to reduce to

:control distanceMetric:

   The distance metric to use (integer, 0-6, see flags above)

:control numNeighbours:

   The number of neighbours considered by the algorithm to balance local vs global structures to conserve. Low values will prioritise preserving local structure, high values will help preserving the global structure.

:control minDist:

   The minimum distance each point is allowed to be from the others in the low dimension space. Low values will make tighter clumps, and higher will spread the points more.

:control iterations:

   The number of iterations that the algorithm will go through to optimise the new representation

:control learnRate:

   The learning rate of the algorithm, aka how much of the error it uses to estimate the next iteration.


:message fit:

   :arg dataSet: A :fluid-obj:`DataSet` to analyse

   :arg action: Run when done

   Train this model on a :fluid-obj:`DataSet` but don't transform the data

:message transform:

   :arg sourceDataSet: Source data, or the DataSet name

   :arg destDataSet: Destination data, or the DataSet name

   :arg action: Run when done

   Given a trained model, apply the reduction to a source :fluid-obj:`DataSet` and write to a destination. Can be the same for both input and output (in-place).

:message fitTransform:

   :arg sourceDataSet: Source data, or the DataSet name

   :arg destDataSet: Destination data, or the DataSet name

   :arg action: Run when done

   Fit the model to a :fluid-obj:`DataSet` and write the new projected data to a destination FluidDataSet.

:message transformPoint:

   :arg sourceBuffer: A |buffer| with the new data point.

   :arg destBuffer: A |buffer| to contain the dimensionally reduced data point.

   :arg action: A function to run when processing is complete

   Transform a new data point to the reduced number of dimensions using the projection learned from previous fit call to :fluid-obj:`UMAP`.
