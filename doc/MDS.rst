:digest: Multidimensional Scaling
:species: data
:sc-categories: Dimensionality Reduction, Data Processing
:sc-related: Classes/FluidMDS, Classes/FluidDataSet
:see-also: 
:description: 

   Dimensionality Reduction of a :fluid-obj:`DataSet` Using Multidimensional Scaling

:discussion:

   Multidimensional Scaling transforms a dataset to a lower number of dimensions while trying to preserve the distance relationships between the data points, so that even with fewer dimensions, the differences and similarities between points can still be observed and used effectively. 
   
   First, MDS computes a distance matrix by calculating the distance between every pair of points in the dataset. It then positions all the points in the lower number of dimensions (specified by ``numDimensions``) and iteratively shifts them around until the distances between all the points in the lower number of dimensions is as close as possible to the distances in the original dimensional space.
   
   What makes this MDS implementation more flexible than some of the other dimensionality reduction algorithms in FluCoMa is that MDS allows for different measures of distance to be used (see list below). Note that unlike the other dimensionality reduction algorithms, MDS does not have a ``fit`` or ``transform`` method, nor does it have the ability to transform data points in buffers. This is essentially because the algorithm needs to do the fit & transform as one with just the data provided in the source DataSet and therefore incorporating new data points would require a re-fitting of the model.

   **Manhattan Distance:** The sum of the absolute value difference between points in each dimension. This is also called the Taxicab Metric. https://en.wikipedia.org/wiki/Taxicab_geometry
   
   **Euclidean Distance:** Square root of the sum of the squared differences between points in each dimension (Pythagorean Theorem) https://en.wikipedia.org/wiki/Euclidean_distance This metric is the default, as it is the most commonly used.
   
   **Squared Euclidean Distance:** Square the Euclidean Distance between points. This distance measure more strongly penalises larger distances, making them seem more distant, which may reveal more clustered points. https://en.wikipedia.org/wiki/Euclidean_distance#Squared_Euclidean_distance
   
   **Minkowski Max Distance:** The distance between two points is reported as the largest difference between those two points in any one dimension. Also called the Chebyshev Distance or the Chessboard Distance. https://en.wikipedia.org/wiki/Chebyshev_distance
   
   **Minkowski Min Distance:** The distance between two points is reported as the smallest difference between those two points in any one dimension.
   
   **Symmetric Kullback Leibler Divergence:** The Symmetric Kullback Leibler Divergence computes the distance between two points by finding the relative entropy when comparing each to the other: given point A, how likely is point B, and, given point B, how likely is point A? These differences sum to create the measured distance between two points. Because the first part of this computation uses the logarithm of the values, using the Symmetric Kullback Leibler Divergence only makes sense with non-negative data. https://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence#Symmetrised_divergence
   
   **Cosine Distance:** Cosine Distance considers each data point a vector in Cartesian space and computes the angle between the two points. It first normalizes these vectors so they both sit on the unit circle and then finds the dot product of the two vectors which returns a calculation of the angle. Therefore this measure does not consider the magnitudes of the vectors when computing distance. https://en.wikipedia.org/wiki/Cosine_similarity (This article describes the cosine _similarity_, as opposed to distance, however since the cosine similarity is always between -1 and 1, the distance is computed as 1 - cosine similarity, which will always range from a minimum distance of 0 to a maximum distance of 2.)

:control numDimensions:

   The number of dimensions to reduce to

:control distanceMetric:

   The distance metric to use (integer 0-6)
   
   :enum:
    
    :0: 
      Manhattan Distance

    :1: 
      Euclidean Distance (default)

    :2: 
      Squared Euclidean Distance

    :3: 
      Minkowski Max Distance

    :4: 
      Minkowski Min Distance

    :5: 
      Symmetric Kullback Leibler Divergance

    :6: 
      Cosine Distance

:message fitTransform:

   :arg sourceDataSet: Source DataSet

   :arg destDataSet: Destination DataSet

   :arg action: Run when done

   Fit the model to a :fluid-obj:`DataSet` and write the new projected data to a destination DataSet.
