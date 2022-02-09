:digest: Classify data with K Nearest Neighbours
:species: data
:sc-categories: Classification, KNN
:sc-related: Classes/FluidKNNRegressor, Classes/FluidDataSet, Classes/FluidLabelSet
:see-also: 
:description: A nearest-neighbour classifier using :fluid-obj:`KDTree` . Each point is assigned the class that is most common among its nearest neighbours. https://scikit-learn.org/stable/modules/neighbors.html#classification


:control numNeighbours:

   the number of neighours to consider

:control weight:

   true / false: whether the neighbours should be weighted by distance


:message fit:

   :arg dataSet: Source data

   :arg labelSet: Labels for the source data

   :arg action: Run when done

   Fit the model to a source :fluid-obj:`DataSet` and a target :fluid-obj:`LabelSet`. These need to be the same size

:message predict:

   :arg dataSet: data to predict labels for

   :arg labelSet: place to write labels

   :arg action: Run when done

   Given a fitted model, predict labels for a :fluid-obj:`DataSet` and write these to a :fluid-obj:`LabelSet`

:message predictPoint:

   :arg buffer: A data point

   :arg action: Run when done, passes predicted label as argument

   Given a fitted model, predict labels for a data point in a |buffer| and return these to the caller
