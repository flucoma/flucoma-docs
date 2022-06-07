:digest: Regression with K Nearest Neighbours
:species: data
:sc-categories: Regression
:sc-related: Classes/FluidKNNClassifier, Classes/FluidDataSet
:see-also: 
:description: Regression between DataSets using weighted average of neighbours
:discussion:
   
   KNNRegressor is a supervised machine learning algorithm for regression. In order to make predictions, the KNNRegressor must first be ``fit`` with an input :fluid-obj:`DataSet` of data points, each of which is paired (by means of a shared identifier) with another data point in an output DataSet.

   It uses an internal ``KDTree`` to find an input point's ``numNeighbours`` nearest neighbours in an input dataset. The output returned is a weighted average of those neighbours' values from the output DataSet.
   
   The output DataSet must have only 1 dimension.

:control numNeighbours:

   Number of neighbours to consider when interpolating the regressed value. The default is 3.

:control weight:

   Whether to weight neighbours by distance when producing new point. The default is 1 (true).

:message fit:

   :arg sourceDataSet: input :fluid-obj:`DataSet`

   :arg targetDataSet: output :fluid-obj:`DataSet` containing only one dimension.

   :arg action: Run when done

   Map an input :fluid-obj:`DataSet` to a one-dimensional output DataSet.

:message predict:

   :arg sourceDataSet: input :fluid-obj:`DataSet`

   :arg targetDataSet: a :fluid-obj:`DataSet` to write the predictions into

   :arg action: Run when done

   Apply learned mapping to a :fluid-obj:`DataSet` and write predictions to an output DataSet

:message predictPoint:

   :arg buffer: data point

   :arg action: Run when done

   Apply learned mapping to a data point in a |buffer| the predicted value is returned.
