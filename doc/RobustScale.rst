:digest: Apply Robust Scaling to a FluidDataSet
:species: data
:sc-categories: FluidManipulation
:sc-related: Classes/FluidStandardize, Classes/FluidNormalize, Classes/FluidDataSet
:see-also: 
:description: 

   Apply Robust Scaling to a :fluid-obj:`DataSet` based on statistics of the data such that each dimension has a median centred on 0 and a range of 1 from the ``low`` percentile to the ``high`` percentile.

:discussion:
   
   For example, using the default values for ``low`` (25) and ``high``, RobustScale will find the range between the 25th and 75th percentile for each dimension and then scale each dimension accordingly so the range between the 25th and 75th percentile the scaled data is 1. RobustScale also offsets each dimension so the median is centred on 0. 
   
   Because RobustScale is based on percentiles, it is less affected by extreme outliers than other scalers (such as Standardize and Normalize). This may help RobustScale position the majority of the data in a -1 to 1 -ish range better than other scalers.

:control low:

   The low percentile boundary. The default is 25.

:control high:

   The high percentile boundary. The default is 75.

:message fit:

   :arg dataSet: The :fluid-obj:`DataSet` to determine the statistics of.

   Compute the scaling factors from a :fluid-obj:`DataSet` for later.

:message transform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to scale

   :arg destDataSet: The :fluid-obj:`DataSet` to write the scaled data to.

   Scale a :fluid-obj:`DataSet` into another :fluid-obj:`DataSet`, using the learned statistics from the previous call to :fluid-obj:`RobustScale#fit`

 :message inverseTransform:

    :arg sourceDataSet: The :fluid-obj:`DataSet` to inverse scale

    :arg destDataSet: The :fluid-obj:`DataSet` to write the scaled data to.

    Inverse scale a :fluid-obj:`DataSet` into another :fluid-obj:`DataSet`: going from the range of the scaled data back to the range of the data that was used in the previous call to :fluid-obj:`RobustScale#fit`
      
:message fitTransform:

   :arg sourceDataSet: The :fluid-obj:`DataSet` to determine the statistics of and scale.

   :arg destDataSet: The :fluid-obj:`DataSet` to write the scaled data to.

   Scale a :fluid-obj:`DataSet`

:message transformPoint:

   :arg sourceBuffer: A |buffer| with a data point

   :arg destBuffer: A |buffer| to write the scaled values to

   Scale a data point, using the learned statistics from the previous call to :fluid-obj:`RobustScale#fit`
   
 :message inverseTransformPoint:

    :arg sourceBuffer: A |buffer| with a data in the scaled range

    :arg destBuffer: A |buffer| to write the un-scaled values in the original range to

    Inverse scale a data point, going from the range of the scaled data back to the range of the DataSet that was used for ``fit``.
