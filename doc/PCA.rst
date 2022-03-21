:digest: Dimensionality Reduction with Principal Component Analysis
:species: data
:sc-categories: Dimensionality Reduction, Data Processing
:sc-related: Classes/FluidMDS, Classes/FluidDataSet
:see-also: 
:description: 
   Principal Components Analysis of a :fluid-obj:`DataSet`

   https://scikit-learn.org/stable/modules/decomposition.html#principal-component-analysis-pca



:control numDimensions:

   The number of dimensions to reduce to


:message fit:

   :arg dataSet: A :fluid-obj:`DataSet` to analyse

   :arg action: Run when done

   Train this model on a :fluid-obj:`DataSet` but don't transform the data

:message transform:

   :arg sourceDataSet: Source data, or the DataSet name

   :arg destDataSet: Destination data, or the DataSet name

   :arg action: Run when done

   Given a trained model, apply the reduction to a source :fluid-obj:`DataSet` and write to a destination. Can be the same for both input and output (in-place). Returns the fraction of accounted variance, aka the fidelity of the new representation: a value near 1.0 means a higher fidelity to the original.

:message fitTransform:

   :arg sourceDataSet: Source data, or the DataSet name

   :arg destDataSet: Destination data, or the DataSet name

   :arg action: Run when done

   :fluid-obj:`PCA#fit` and :fluid-obj:`PCA#transform` in a single pass. Returns the fraction of accounted variance, aka the fidelity of the new representation: a value near 1.0 means a higher fidelity to the original.

:message transformPoint:

   :arg sourceBuffer: Input data

   :arg destBuffer: Output data

   :arg action: Run when done

   Given a trained model, transform the data point in ``sourceBuffer`` from the original dimensional space to ``numDimensions`` principal components and write into ``destBuffer``.

:message inverseTransformPoint:

  :arg sourceBuffer: Input data

  :arg destBuffer: Output data

  :arg action: Run when done

  Given a trained model, transform the data point in ``sourceBuffer`` from being ``numDimensions`` principal components into the original dimensional space and write into ```destBuffer``.
