:digest: Normalize a FluidDataSet
:species: data
:sc-categories: FluidManipulation
:sc-related: Classes/FluidStandardize, Classes/FluidDataSet
:see-also: Standardize, RobustScale
:description: Normalize the entries of a :fluid-obj:`DataSet`, or normalize a data point according to the learned bounds of a data set.


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

   Transform a :fluid-obj:`DataSet` using learned extrema from :fluid-obj:`Normalize#fit` and copy the results to the destination :fluid-obj:`DataSet`.

:message fitTransform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to normalize

   :arg destDataSet: The :fluid-obj:`DataSet` to populate with normalized data

   Normalize a :fluid-obj:`DataSet` and copy the results to :fluid-obj:`DataSet`.

:message transformPoint:

   :arg sourceBuffer: A |buffer| with the new data point

   :arg destBuffer: A |buffer| to contain the normalized value

   Normalize a single data point, using the learned extrema from a previous call to :fluid-obj:`Normalize#fit`
