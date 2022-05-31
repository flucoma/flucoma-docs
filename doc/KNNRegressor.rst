:digest: Regression with K Nearest Neighbours
:species: data
:sc-categories: Regression
:sc-related: Classes/FluidKNNClassifier, Classes/FluidDataSet, Classes/FluidMLPRegressor
:see-also: 
:description: 
   A nearest-neighbour regressor: a continuous value is predicted as the (weighted) average value of its nearest neighbours.

:discussion:

  In order to make predictions, the KNNRegressor must first be ``fit`` with input-output example pairs, supplied by a :fluid-obj:`DataSet` of input data points and a :fluid-obj:`DataSet` of corresponding output data points. The input-output example pairs correspond in their respective :fluid-obj:`DataSet`s by means of a shared identifier.

  To provide a regression prediction for an input point, ``numNeighbours`` neighbours are determined for the input point and a weighted average (based on distance) of those points is returned. (Weighting by distance can optionally be turned off, using the ``weight`` parameter.)

:control numNeighbours:

   Number of neighbours to consider when making predictions.

:control weight:

   Whether to weight neighbours by distance when producing new point. The default is 1 (true).

:message fit:

   :arg sourceDataSet: :fluid-obj:`DataSet` containing input exmaples.

   :arg targetDataSet: :fluid-obj:`DataSet` containing output exmaples.

   :arg action: Run when done

   Map a source :fluid-obj:`DataSet` to a one-dimensional target; both DataSets need to have the same number of points.

:message predict:

   :arg sourceDataSet: data to regress

   :arg targetDataSet: output data

   :arg action: Run when done

   Apply learned mapping to a :fluid-obj:`DataSet` and write to an output DataSet

:message predictPoint:

   :arg buffer: data point

   :arg action: Run when done

   Apply learned mapping to a data point in a |buffer|
