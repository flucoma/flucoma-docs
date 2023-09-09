:digest: Series Classification with K-Nearest Neighbours using Dynamic Time Warping
:species: data
:sc-categories: Classification, DTW
:sc-related: 
:see-also: DTW, DataSeries, LabelSet
:description: A nearest neighbour classifier using a :fluid-obj:`DTW`.

:discussion:
  
   To keep with the interface of the :fluid-obj:`DTWClassifier`, the DTWClassifier must first be ``fit`` with a :fluid-obj:`DataSeries` of data points and a target :fluid-obj:`LabelSet` with a label for each point in the DataSeries (by means of a shared identifier).
  
   To classify a point, ``numNeighbours`` neighbours are determined for the incoming point, and each of those neighbours' label is given a score based on the distance to the target, neighbours with the same label only increase the likelyhood of that label being considered the nearest. The label with the highest score is considered to be the closest and returned.

   Keep in mind that this is a brute-force measure, so evaluation will become very slow for large numbers of points or long series.

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

   Given the fitted model, predict labels for a :fluid-obj:`DataSeries` and write these to a :fluid-obj:`LabelSet`


:message predictPoint:

   :arg buffer: A data series stored in a |buffer|

   Given a fitted model, predict a label for a data point in |buffer| and return to the caller


:message clear:

   Clears the :fluid-obj:`DataSeries` and :fluid-obj:`LabelSet`


