:digest: Classification with K Nearest Neighbours
:species: data
:sc-categories: Classification, KNN
:sc-related: Classes/FluidKNNRegressor, Classes/FluidDataSet, Classes/FluidLabelSet, Classes/MLPClassifier
:see-also: 
:description: A nearest-neighbour classifier using a :fluid-obj:`KDTree` .

:discussion:
  
  In order to make predictions, the KNNClassifier must first be ``fit`` with a :fluid-obj:`DataSet` of data points and a target :fluid-obj:`LabelSet` with a label for each point in the DataSet (by means of a shared identifier).
  
  To classify a point, ``numNeighbours`` neighbours are determined for the incoming point and whichever class is most common among the neighbours is predicted as the class for the point. If an even number of ``numNeighbours`` is requested and there is a tie, the label with the closer point will be predicted.

:control numNeighbours:

   The number of neighbours to consider

:control weight:

   Whether the neighbours should be weighted by their distance so that closer points have more influence over determining the class. The default is 1 (true).

:message fit:

   :arg dataSet: Source :fluid-obj:`DataSet`

   :arg labelSet: A :fluid-obj:`LabelSet` of labels for the source ``dataSet``

   :arg action: Run when done

   Fit the model to a source :fluid-obj:`DataSet` and a target :fluid-obj:`LabelSet`. The labels in the :fluid-obj:`LabelSet` correspond to the data points in the :fluid-obj:`DataSet` by means of a shared identifier.

:message predict:

   :arg dataSet: :fluid-obj:`DataSet` of data points to predict labels for

   :arg labelSet: :fluid-obj:`LabelSet` to write the predicted labels into

   :arg action: Run when done

   Given a fitted model, predict labels for a :fluid-obj:`DataSet` and write these to a :fluid-obj:`LabelSet`

:message predictPoint:

   :arg buffer: A data point

   :arg action: Run when done, passes predicted label as argument

   Given a fitted model, predict a label for a data point in ``buffer`` and return to the caller
