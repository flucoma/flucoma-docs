:digest: Standardize a FluidDataSet
:species: data
:sc-categories: FluidManipulation
:sc-related: Classes/FluidDataSet, Classes/FluidStandardize
:see-also: 
:description: 
   Standardize a :fluid-obj:`DataSet`. Rescale using its mean(s) and standard deviation(s) in each dimension, such that each dimension has a mean of 0 and a standard deviation of 1.
   
:discussion:

:message fit:

   :arg dataSet: The :fluid-obj:`DataSet` to learn the statistics of (mean and standard deviation)

   :arg action: A function to run when processing is complete

   Fit model to a DataSet without applying scaling

:message transform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to standardize

   :arg destDataSet: The :fluid-obj:`DataSet` to write the standardized data into

   :arg action: A function to run when processing is complete

   Standardize a :fluid-obj:`DataSet`, using the learned statistics from a previous call to ``fit``

:message fitTransform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to first ``fit`` to and then standardize

   :arg destDataSet: The :fluid-obj:`DataSet` to populate with standardized data

   :arg action: A function to run when processing is complete

   ``fit`` the model to the ``sourceDataSet`` and then standardize the ``sourceDataSet`` and write into ``destDataSet``

:message inverseTransform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to of data to transform from the standardized scale to the original scale.

   :arg destDataSet: The :fluid-obj:`DataSet` to write the transformed data to.

   :arg action: A function to run when processing is complete

   Un-standardize a :fluid-obj:`DataSet`, using the learned statistics from a previous call to ``fit``.

:message transformPoint:

   :arg sourceBuffer: A |buffer| with source data to standardize

   :arg destBuffer: A |buffer| to write the standardized data into

   :arg action: A function to run when processing is complete

   Standardize a data point, using the learned statistics from a previous call to ``fit``
   
:message inverseTransformPoint:

  :arg sourceBuffer: A |buffer| with the data in the stadardized range

  :arg destBuffer: A |buffer| to write the output of the transformation to

  :arg action: A function to run when processing is complete

  Un-standardize a data point, using the learned statistics from a previous call to ``fit``
