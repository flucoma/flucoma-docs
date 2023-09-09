:digest: A set of data series associated with identifiers.
:species: data
:sc-categories: UGens>FluidManipulation
:sc-related: Classes/Dictionary
:see-also: LabelSet, DataSet, DTW
:max-seealso: dict
:description: FluidDataSeries is a container associating series of data points with identifiers
:control name:

   The name of the FluidDataSeries. This is unique between all FluidDataSeries.

:message addFrame:

   :arg identifier: The identifier for the series to add to.

   :arg buffer: A |buffer| containing the data for the frame (only the first channel is used).
 
   Add a new frame to the end of a series, creates the series if it does not exist. Sets the dimensionality of the DataSeries if it is the first frame added, otherwise if the buffer is too short an error will be reported.

:message addSeries:

   :arg identifier: The identifier for the series to add.

   :arg buffer: A |buffer| containing the data for the series (each channel is a distinct time frame).

   Add a new series from a buffer. Sets the dimensionality of the DataSeries if it is the first series added, otherwise if the buffer is too short an error will be reported. If the identifier already exists an error will be reported.

:message getFrame:

   :arg identifier: The identifier for the series to get from.

   :arg time: which time frame to get.

   :arg buffer: A |buffer| to write the frame to (only the first channel is used, will be resized).
 
   Get a frame from a series. If the identifier doesn't exist or if that series doesnt have a frame for that time point an error will be reported.

:message getSeries:

   :arg identifier: The identifier for the series to get.

   :arg buffer: A |buffer| to write the series to (each channel is a distinct time frame, will be resized).

   Get a series. If the identifier doesn't exist an error will be reported.

:message setFrame:

   :arg identifier: The identifier for the series to set a frame in.

   :arg time: which time frame to set.

   :arg buffer: A |buffer| containing the data for the frame (only the first channel is used).
 
   Updates a time frame in a series, or adds it to the end if there is no frame at that time point. Sets the dimensionality of the DataSeries if it is the first frame added, otherwise if the buffer is too short an error will be reported.

:message setSeries:

   :arg identifier: The identifier for the series to set.

   :arg buffer: A |buffer| containing the data for the series (each channel is a distinct time frame).

   Updates a time series, or adds it if it doesn't exist. Sets the dimensionality of the DataSeries if it is the first series added, otherwise if the buffer is too short an error will be reported.

:message updateFrame:

   :arg identifier: The identifier for the series to update a frame in.

   :arg time: which time frame to update.

   :arg buffer: A |buffer| containing the data for the frame (only the first channel is used).
 
   Updates an existing frame. If the buffer is too short an error will be reported. If the identifier doesn't exist or if that series doesnt have a frame for that time point an error will be reported.

:message updateSeries:

   :arg identifier: The identifier for the series to update.

   :arg buffer: A |buffer| containing the data for the series (each channel is a distinct time frame).

   Updates a new series. If the buffer is too short an error will be reported. If the identifier doesn't exist an error will be reported.

:message deleteFrame:

   :arg identifier: The identifier for the series to delete a frame from.

   :arg time: which time frame to remove.
 
   Delete a frame from a series, deletes the series if it is the only frame. If the identifier doesn't exist or if that series doesnt have a frame for that time point an error will be reported.

:message deleteSeries:

   :arg identifier: The identifier for the series to delete.

   Delete a series. If the identifier doesn't exist an error will be reported.

:message getDataSet:

   :arg dataSet: The Dataset to write the slice to. Will overwrite and resize.

   :arg time: which time frame to extract.

   Get a dataset with the `time`th frame of every series, i.e. can create a :fluid-obj:`DataSet` with every Nth frame of every series. If an identifier doesn't have enough frames it is merely not added to the output dataset.

:message clear:

   Empty the data series of all series and frames.

:message getIds:

   :arg labelSet: The FluidLabelSet to export to. Its content will be replaced.

   Export the dataseries identifiers to a :fluid-obj:`LabelSet`.

:message merge:

   :arg sourceDataSeries: The source DataSeries to be merged.

   :arg overwrite: A flag to allow overwrite points with the same identifier.

   Merge sourceDataSeries in the current DataSeries. It will replace the value of points with the same identifier if overwrite is set to 1.

:message kNearest:

   :arg buffer: A |buffer| containing a data point to match against.

   :arg k: The number of nearest neighbours to return.

   Returns the identifiers of the ``k`` points nearest to the one passed in distance order (closest first). Note that this is a brute force distance measure, and inefficient for repeated queries against large dataseries.

:message kNearestDist:

   :arg buffer: A |buffer| containing a data point to match against. The number of frames in the buffer must match the dimensionality of the DataSet.

   :arg k: The number of nearest neighbours to return. The identifiers will be sorted, beginning with the nearest.

   Returns the distances to the ``k`` points nearest to the one passed in descending order. Note that this is a brute force distance measure, and inefficient for repeated queries against large dataseries.

:message print:

   Post an abbreviated content of the DataSeries in the window by default, but you can supply a custom action instead. 

:message read:

   :arg filename: optional, filename to save to

   Read a saved object in JSON format from disk, will prompt for file location if not filename not provided

:message write:

   :arg filename: optional, filename to save to

   Save the contents of the object to a JSON file on disk to the file specified, will prompt for file location if not filename not provided

:message load:

   Load the state of this object from a Dictionary.

:message dump:

   Dump the state of this object as a Dictionary.
