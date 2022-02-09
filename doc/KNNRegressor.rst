:digest: Regression with K Nearest Neighbours
:species: data
:sc-categories: Regression
:sc-related: Classes/FluidKNNClassifier, Classes/FluidDataSet
:see-also: 
:description: 
   A nearest-neighbour regressor. A continuous value is predicted for each point as the (weighted) average value of its nearest neighbours.

   https://scikit-learn.org/stable/modules/neighbors.html#regression



:control numNeighbours:

   number of neigbours to consider in mapping, min 1

:control weight:

   Whether to weight neighbours by distance when producing new point


:message fit:

   :arg sourceDataSet: Source data

   :arg targetDataSet: Target data

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
