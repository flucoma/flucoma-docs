:digest: Apply Robust Scaling to a FluidDataSet
:species: data
:sc-categories: FluidManipulation
:sc-related: Classes/FluidStandardize, Classes/FluidNormalize, Classes/FluidDataSet
:see-also: 
:description: 

   Standardize a :fluid-obj:`DataSet`. Rescale using its mean(s) and standard deviation(s) in each dimension, such that each dimension has a mean of 0 and a standard deviation of 1.
  
   Scale the entries of a DataSet, or scales a data point according to the learned values of a data set. It will centre the median of each dimension to 0, and will scale the data to +/- the provided centiles, by default providing the first and third qartile (25 and 75).

:control low:

   The low centile boundary, default 25.

:control high:

   The high centile boundary, default 75.

:control invert:

   The direction in which the scaling will occur for transform and transformpoint. The default 0 is taking in the range of the input used to fit and transforms it towards the robust scaling range. A value of 1 will expect an input of the scaling range to transform back to the original range.


:message fit:

   :arg dataSet: The :fluid-obj:`DataSet` to scale

   :arg action: A function to run when processing is complete

   Compute the scaling factors from a :fluid-obj:`DataSet` for later.

:message transform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to scale

   :arg destDataSet: The :fluid-obj:`DataSet` to populate with scaled data

   :arg action: A function to run when processing is complete

   Scale a :fluid-obj:`DataSet` into another :fluid-obj:`DataSet`, using the learned range from a previous call to :fluid-obj:`RobustScale#fit`

:message fitTransform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to scale

   :arg destDataSet: The :fluid-obj:`DataSet` to populate with scaled data

   :arg action: A function to run when processing is complete

   Scale a :fluid-obj:`DataSet`

:message transformPoint:

   :arg sourceBuffer: A |buffer| with the new data point

   :arg destBuffer: A |buffer| to contain the scaled value

   :arg action: A function to run when processing is complete

   Scale a new data point, using the learned extrema from a previous call to :fluid-obj:`RobustScale#fit`
