:digest: Series Regression with K-Nearest Neighbours using Dynamic Time Warping
:species: data
:sc-categories: Regression, DTW
:sc-related: 
:see-also: DTW, DataSeries, DataSet
:description: A nearest neighbour classifier using a :fluid-obj:`DTW`.

:discussion:
  
   To keep with the interface of the :fluid-obj:`DTWRegressor`, the DTWRegressor must first be ``fit`` with a :fluid-obj:`DataSeries` of data points and a target :fluid-obj:`DataSet` with a mapping for each point in the DataSeries (by means of a shared identifier).
  
   To calculate a point, ``numNeighbours`` neighbours are determined for the incoming point, and a distance-weighted sum of those neighbours' corresponding outputs is returned.

   Keep in mind that this is a brute-force measure, so evaluation will become very slow for large numbers of points or long series.

   See https://rtavenar.github.io/blog/dtw.html for an explanation of the DTW algorithm, though it can roughly be summed up as a metric measuring the similarity between two sime series, while accounting for the fact that features arent necessarily the same length.

:control numNeighbours:

   The number of neighbours to consider

:control constraint:

   The constraint to use in the `DTW` algorithm when calculating the distance between two time series. 'Warping' in this context means how distorted the genral shape of the series is.
   For example, a pulse with a fast attack and slow decay will register as identical to the case with fast decay and slow attack, since stretching the time series can make it match in shape. If constraints are applied however, the amount of warping is restricted, so that the general shape of the series is kept.

   See https://rtavenar.github.io/blog/dtw.html#setting-additional-constraints for a beautiful visual explanation of the constraints

   :enum:
     
      :0: 
      **unconstrained** (any point can warp to any other)
   
      :1: 
      **ikatura** (the start and end can only warp a little, whereas the middle can warp more)
   
      :2: 
      **sakoe-chiba** (each point can only warp within a certain radius)


:control radius:

   The maximum radius a frame can warp away from its initial location when using a ``sakoe-chiba`` constraint. A higher value results in being able to warp more


:control gradient:
 
   Parameter for the ``ikatura`` constraint. A higher value results in being able to warp more.


:message fit:

   :arg dataSeries: Source :fluid-obj:`DataSeries`

   :arg labelSet: A :fluid-obj:`LabelSet` of labels for the source :fluid-obj:`DataSet`

   Fit the model to a source :fluid-obj:`DataSeries` and a target :fluid-obj:`LabelSet`. The labels in the :fluid-obj:`LabelSet` correspond to the data points in the :fluid-obj:`DataSeries` by means of a shared identifier.


:message predict:

   :arg dataSeries: A :fluid-obj:`DataSeries` of data series to predict labels for

   :arg labelSet: A :fluid-obj:`LabelSet` to write the predicted labels into

   Given the fitted model, predict the output for a :fluid-obj:`DataSeries` and write these to a :fluid-obj:`DataSet`


:message predictPoint:

   :arg buffer: A data series stored in a |buffer|

   Given a fitted model, predict the output for a data point in |buffer| and return to the caller


:message clear:

   Clears the :fluid-obj:`DataSeries` and :fluid-obj:`LabelSet`


