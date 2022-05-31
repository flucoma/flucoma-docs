:digest: Principal Component Analysis
:species: data
:sc-categories: Dimensionality Reduction, Data Processing
:sc-related: Classes/FluidMDS, Classes/FluidDataSet
:see-also: 
:description: 
   Principal Components Analysis (PCA) of a :fluid-obj:`DataSet`. 
  
:discussion:

   PCA fits to a DataSet to determine its principal components, each of which is a new axis through the data that maximises the variance, or “differences”, within the Data. PCA can then transform the original DataSet or individual points to position them in relation to the principal components (i.e., “new axes”) for better comparing how they differ from other points in the DataSet. PCA is often used for dimensionality reduction and is also useful for removing redundancy (i.e., correlation) and/or noise (i.e., dimensions that are uniformly distributed) from a DataSet.

:control numDimensions:

   The number of dimensions (principal components) to keep after a ``transform``, using PCA for dimensionality reduction. 

:message fit:

   :arg dataSet: A :fluid-obj:`DataSet` to analyse

   :arg action: Run when done

   Train this model on a :fluid-obj:`DataSet` to determine the principal components, but don't transform any data.

:message transform:

   :arg sourceDataSet: source DataSet

   :arg destDataSet: destination DataSet

   :arg action: Run when done

   Given a trained model, transform a source :fluid-obj:`DataSet` into the PCA-space and write to a destination DataSet. The DataSets can be the same for both input and output (performs the operation in-place). This process returns the fraction (between 0 and 1) of explained variance.
   
:message inverseTransform:

   :arg sourceDataSet: source DataSet

   :arg destDataSet: destination DataSet

   :arg action: Run when done

   Given a trained model, invert a source :fluid-obj:`DataSet` containing ``numDimensions`` dimensions that are in PCA-space to a destination :fluid-obj:`DataSet` with the dimensionality of the data that was used to ``fit``. :fluid-obj:`DataSet` can be the same for both input and output (the operation will be performed in-place). 

:message fitTransform:

   :arg sourceDataSet: source DataSet

   :arg destDataSet: destination DataSet

   :arg action: Run when done

   :fluid-obj:`PCA#fit` and :fluid-obj:`PCA#transform` in a single pass. Returns the fraction (between 0 and 1) of explained variance.

:message transformPoint:

   :arg sourceBuffer: Input data

   :arg destBuffer: Output data

   :arg action: Run when done

   Given a trained model, transform the data point in ``sourceBuffer`` from the original dimensional space to ``numDimensions`` in PCA-space and write into ``destBuffer``.

:message inverseTransformPoint:

  :arg sourceBuffer: Input data

  :arg destBuffer: Output data

  :arg action: Run when done

  Given a trained model, transform the data point in ``sourceBuffer`` from being ``numDimensions`` in PCA-space into the original dimensional space and write into ```destBuffer``.
