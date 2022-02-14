:digest: Dimensionality Reduction with Multidimensional Scaling
:species: data
:sc-categories: Dimensionality Reduction, Data Processing
:sc-related: Classes/FluidMDS, Classes/FluidDataSet
:see-also: 
:description: 
   Multidimensional scaling of a :fluid-obj:`DataSet`

   https://scikit-learn.org/stable/modules/manifold.html#multi-dimensional-scaling-mds



:control numDimensions:

   The number of dimensions to reduce to

:control distanceMetric:

   The distance metric to use (integer, 0-6, see flags above)


:message fitTransform:

   :arg sourceDataSet: Source data, or the DataSet name

   :arg destDataSet: Destination data, or the DataSet name

   :arg action: Run when done

   Fit the model to a :fluid-obj:`DataSet` and write the new projected data to a destination FluidDataSet.
