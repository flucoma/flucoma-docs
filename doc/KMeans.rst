:digest: Cluster data points with K-Means
:species: data
:sc-categories: FluidManipulation
:sc-related:
:see-also: SKMeans, KNNClassifier, MLPClassifier, DataSet, LabelSet
:description: 

   Uses the K-means algorithm to learn clusters from a :fluid-obj:`DataSet`.

:discussion:

   ``KMeans`` facilitates learning of clusters from a :fluid-obj:`DataSet`. This allows you to assign each point in the data a discrete membership to a group or cluster. The algorithm works by partitioning points into discrete clumps that ideally have *equal variance*. See the Scitkit-learn reference for a more technical explanation: https://scikit-learn.org/stable/modules/clustering.html#k-means

:control numClusters:

   The number of clusters to classify data into.

:control maxIter:

   The maximum number of iterations the algorithm will use whilst fitting.

:control initMethod:

   The method used to initialize the clustering process. 
   
   :enum:

     :0:
        random partition: each input point is randomly assigned to a cluster.

     :1:
        random means: the initial means are sampled at random from the input points, which are then assigned to their nearest mean.

     :2:
        sampling: the initial means are sampled from the input points, weighted by an approximation of the input data distribution. 

:control seed:

   The seed provided to the pseudo-random number generator used within the algorithm. This allows for repeatable results from these generators; the same seed will consistently produce the same result. The default is -1, which requests a 'real' random, unpredictable seed.

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

:message transform:

   :arg srcDataSet: A :fluid-obj:`DataSet` containing the data to transform.

   :arg dstDataSet: A :fluid-obj:`DataSet` to contain the new cluster-distance space.

   :arg action: A function to run when the server responds.

   Given a trained object, return for each item of a provided :fluid-obj:`DataSet` its distance to each cluster as an array, often referred to as the cluster-distance space.

:message fitTransform:

   :arg srcDataSet: A :fluid-obj:`DataSet` containing the data to fit and transform.

   :arg dstDataSet: A :fluid-obj:`DataSet` to contain the new cluster-distance space.

   :arg action: A function to run when the server responds

   Run ``fit`` and ``transform`` in a single pass: i.e. train the model on the incoming :fluid-obj:`DataSet` and then return its cluster-distance space in the destination :fluid-obj:`DataSet`

:message transformPoint:

   :arg sourceBuffer: A |buffer| containing a data point.

   :arg targetBuffer: A |buffer| to write in the distance to all the cluster centroids.

   :arg action: A function to run when complete.

   Given a trained object, return the distance of the provided point to each cluster centroid. Both points are handled as |buffer|

:message getMeans:

   :arg dataSet: A :fluid-obj:`DataSet` of clusters with a mean per column.

   :arg action: A function to run when complete.

   Given a trained object, retrieve the means (centroids) of each cluster as a :fluid-obj:`DataSet`

:message setMeans:

   :arg dataSet: A :fluid-obj:`DataSet` of clusters with a mean per column.

   :arg action: A function to run when complete.

   Overwrites the means (centroids) of each cluster, and declare the object trained.

:message clear:

   :arg action: A function to run when complete.

   Reset the object status to not fitted and untrained.
