:digest: K-Means with Spherical Distances
:species: data
:sc-categories: FluidManipulation
:sc-related: Classes/FluidDataSet, Classes/FluidLabelSet, Classes/FluidKNNClassifier, Classes/FluidKNNRegressor, Classes/FluidKMeans
:see-also: KMeans, KNNClassifier, MLPClassifier, DataSet
:description: 

   Uses K-means algorithm with cosine similarity to learn clusters and features from a :fluid-obj:`DataSet`.

:discussion:

   :fluid-obj:`SKMeans` is an implementation of KMeans based on cosine distances instead of euclidean ones, measuring the angles between the normalised vectors. 
   One common application of spherical KMeans is to try and learn features directly from input data (via a :fluid-obj:`DataSet`) without supervision. See this reference for a more technical explanation: https://machinelearningcatalogue.com/algorithm/alg_spherical-k-means.html and https://www-cs.stanford.edu/~acoates/papers/coatesng_nntot2012.pdf for feature extractions.

:control numClusters:

   The number of clusters to partition data into.
   
:control encodingThreshold:

   The encoding threshold (aka the alpha parameter). When used for feature learning, this can be used to produce sparser output features by setting the least active output dimensions to 0.

:control maxIter:

   The maximum number of iterations the algorithm will use whilst fitting.

:message fit:

   :arg dataSet: A :fluid-obj:`DataSet` of data points.

   :arg action: A function to run when fitting is complete, taking as its argument an array with the number of data points for each cluster.

   Identify ``numClusters`` clusters in a :fluid-obj:`DataSet`. It will optimise until no improvement is possible, or up to ``maxIter``, whichever comes first. Subsequent calls will continue training from the stopping point with the same conditions.

:message predict:

   :arg dataSet: A :fluid-obj:`DataSet` containing the data to predict.

   :arg labelSet: A :fluid-obj:`LabelSet` to retrieve the predicted clusters.

   :arg action: A function to run when the server responds.

   Given a trained object, return the cluster ID for each data point in a :fluid-obj:`DataSet` to a :fluid-obj:`LabelSet`.

:message fitPredict:

   :arg dataSet: A :fluid-obj:`DataSet` containing the data to fit and predict.

   :arg labelSet: A :fluid-obj:`LabelSet` to retrieve the predicted clusters.

   :arg action: A function to run when the server responds

   Run ``fit`` and ``predict`` in a single pass: i.e. train the model on the incoming :fluid-obj:`DataSet` and then return the learned clustering to the passed :fluid-obj:`LabelSet`

:message predictPoint:

   :arg buffer: A |buffer| containing a data point.

   :arg action: A function to run when the server responds, taking the ID of the cluster as its argument.

   Given a trained object, return the cluster ID for a data point in a |buffer|

:message encode:

   :arg srcDataSet: A :fluid-obj:`DataSet` containing the data to encode.

   :arg dstDataSet: A :fluid-obj:`DataSet` to contain the new cluster-activation space.

   :arg action: A function to run when the server responds.

   Given a trained object, return for each item of a provided :fluid-obj:`DataSet` its encoded activations to each cluster as an array, often referred to as the cluster-activation space.

:message fitEncode:

   :arg srcDataSet: A :fluid-obj:`DataSet` containing the data to fit and encode.

   :arg dstDataSet: A :fluid-obj:`DataSet` to contain the new cluster-activation space.

   :arg action: A function to run when the server responds

   Run ``fit`` and ``encode`` in a single pass: i.e. train the model on the incoming :fluid-obj:`DataSet` and then return its encoded cluster-activation space in the destination :fluid-obj:`DataSet`

:message encodePoint:

   :arg sourceBuffer: A |buffer| containing a data point.

   :arg targetBuffer: A |buffer| to write in the activation to all the cluster centroids.

   :arg action: A function to run when complete.

   Given a trained object, return the encoded activation of the provided point to each cluster centroid. Both points are handled as |buffer|

:message getMeans:

   :arg dataSet: A :fluid-obj:`DataSet` of clusters with a mean per column.

   :arg action: A function to run when complete.

   Given a trained object, retrieve the means (centroids) of each cluster as a :fluid-obj:`DataSet`

:message setMeans:

   :arg dataSet: A :fluid-obj:`DataSet` of clusters with a mean per column.

   :arg action: A function to run when complete.

   Overwrites the means (centroids) of each cluster, and declares the object trained.

:message clear:

   :arg action: A function to run when complete.

   Reset the object status to not fitted and untrained.
