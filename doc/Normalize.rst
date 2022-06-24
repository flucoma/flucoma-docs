:digest: Normalize a FluidDataSet
:species: data
:sc-categories: FluidManipulation
:sc-related: Classes/FluidStandardize, Classes/FluidDataSet
:see-also: Standardize, RobustScale
:description: Normalize a :fluid-obj:`DataSet` or single point of data according to learnt minimum and maximum values.

:control min:

   Minimum output value, default 0

:control max:

   Maximum output value, default 1

:control invert:

   The direction in which the normalization will occur for transform and transformpoint. The default 0 is taking in the range of the input used to fit and transforms it towards the normalised range. A value of 1 will expect an input of the normalized range to transform back to the original range.


:message fit:

   :arg dataSet: The :fluid-obj:`DataSet` to normalize

   Compute the normalization factors from a :fluid-obj:`DataSet` and store them internally.

:message transform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to normalize

   :arg destDataSet: The :fluid-obj:`DataSet` to populate with normalized data

   Transform a :fluid-obj:`DataSet` using learned extrema from ``fit`` and copy the results to the destination :fluid-obj:`DataSet`.

:message fitTransform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to normalize

   :arg destDataSet: The :fluid-obj:`DataSet` to populate with normalized data

   Normalize a :fluid-obj:`DataSet` and copy the results to :fluid-obj:`DataSet`.

:message inverseTransform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to of data to transform from the normalized scale to the original scale.

   :arg destDataSet: The :fluid-obj:`DataSet` to write the transformed data to.

   :arg action: A function to run when processing is complete

   Un-normalize :fluid-obj:`DataSet`, using the learned statistics from a previous call to ``fit``.

:message transformPoint:

   :arg sourceBuffer: A |buffer| with the new data point

   :arg destBuffer: A |buffer| to contain the normalized value

   Normalize a single data point, using the learned extrema from a previous call to ``fit``

:message inverseTransformPoint:

  :arg sourceBuffer: A |buffer| with the data in the normalized range

  :arg destBuffer: A |buffer| to write the output of the transformation to

  :arg action: A function to run when processing is complete

  Un-normalize a data point, using the learned statistics from a previous call to ``fit``