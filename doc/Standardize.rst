:digest: Standardize a FluidDataSet
:species: data
:sc-categories: FluidManipulation
:sc-related: Classes/FluidDataSet, Classes/FluidStandardize
:see-also: 
:description: 
   Standardize a :fluid-obj:`DataSet`, i.e. rescale using its mean(s) and standard deviation(s) in each dimension.

   See http://www.faqs.org/faqs/ai-faq/neural-nets/part2/section-16.html



:control invert:

   The direction in which the standardization will occur for transform and transformpoint. The default 0 is taking in the range of the input used to fit and transforms it towards the standardized range. A value of 1 will expect an input of the standardized range to transform back to the original range.


:message fit:

   :arg dataSet: The :fluid-obj:`DataSet` to standardize

   :arg action: A function to run when processing is complete

   Fit model to a DataSet without applying scaling

:message transform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to standardize

   :arg destDataSet: The :fluid-obj:`DataSet` to populate with standardized data

   :arg action: A function to run when processing is complete

   Standardize a :fluid-obj:`DataSet`, using the learned statistics from a previous call to :fluid-obj:`Standardize#fit`

:message fitTransform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to standardize

   :arg destDataSet: The :fluid-obj:`DataSet` to populate with standardized data

   :arg action: A function to run when processing is complete

   Standardize a :fluid-obj:`DataSet` into another :fluid-obj:`DataSet`

:message transformPoint:

   :arg sourceBuffer: A |buffer| with the new data point

   :arg destBuffer: A |buffer| to contain the standardize value

   :arg action: A function to run when processing is complete

   Standardize a new data point, using the learned statistics from a previous call to :fluid-obj:`Standardize#fit`
