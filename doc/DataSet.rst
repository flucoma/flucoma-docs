:digest: A set of data associated with identifiers.
:species: data
:sc-categories: UGens>FluidManipulation
:sc-related: Classes/FluidLabelSet, Classes/FluidKDTree, Classes/FluidKNNClassifier, Classes/FluidKNNRegressor, Classes/FluidKMeans
:see-also: 
:description: FluidDataSet is a container associating data points with identifiers.


:control name:

   The name of the FluidDataSet. This is unique between all FluidDataSets.


:message addPoint:

   :arg identifier: The identifier for the point.

   :arg buffer: A |buffer| containing the data for the point.
 

   Add a new point to the FluidDataSet. The dimensionality of the FluidDataSet is governed by the size of the first point added. If the identifier already exists, or if the size of the data does not match the dimensionality of the FluidDataSet an error will be reported.

:message updatePoint:

   :arg identifier: The identifier for this point.

   :arg buffer: A |buffer| containing the data for the point.

   Update an existing identifier's data. If the identifier does not exist, or if the size of the data does not match the dimensionality of the FluidDataSet an error will be reported.

:message getPoint:

   :arg identifier: The identifier for the point to be retrieved.

   :arg buffer: A |buffer| where the retrieved data will be stored.

   Retrieve a point from the data set into a |buffer|. If the identifier does not exist an error will be reported.

:message deletePoint:

   :arg identifier: The identifier to be deleted.

   Remove a point from the data set. If the identifier doesn't exist an error will be reported. 

:message setPoint:

   :arg identifier: The identifier for this point.

   :arg buffer: A |buffer| containing the data for the point.

   Set the point. If the identifier exists, this method behaves like updatePoint. If the identifier doesn't exist, it behaves like addPoint.

:message clear:

   Empty the data set. 

:message toBuffer:

   :arg buffer: The buffer to write to. It will be resized.

   :arg transpose: If 0, each dataset point becomes a buffer frame, and each dataset dimension becomes a buffer channel. If 1, points become channels, and dimensions become frames.

   :arg labelSet: The FluidLabelSet in which to dump the point's IDs associated with their reference frame number (or channel number if transposed).

   Dump the content of the dataset to a |buffer|, with optional transposition, and a map of frames/channel to the original IDs as a FluidLabelSet.

:message fromBuffer:

   :arg buffer: The buffer to read from. The dataset will be resized.

   :arg transpose: If 0, each buffer frame becomes a dataset point, and each buffer channel becomes a dataset dimension. If 1, channels become points, and frames become dimensions.

   :arg labelSet: The FluidLabelSet from which to retrieve the point's IDs associated with their reference frame number (or channel number if transposed).

   Import to the dataset the content of a |buffer|, with optional transposition, and a map of frames/channels to the original IDs as a FluidLabelSet.

:message getIds:

   :arg labelSet: The FluidLabelSet to export to. Its content will be replaced.

   Export to the dataset identifier to a FluidLabelSet.

:message merge:

   :arg sourceDataSet: The source DataSet to be merged.

   :arg overwrite: A flag to allow overwrite points with the same identifier.

   Merge sourceDataSet in the current DataSet. It will update the value of points with the same identifier if overwrite is set to 1. ​To add columns instead, see the 'transformJoin' method of FluidDataSetQuery.

:message print:

   Post an abbreviated content of the DataSet in the window by default, but you can supply a custom action instead. 

:message server:

   The server instance the object uses .

:message write:

   Save the contents of the object to a JSON file on disk.

:message dump:

   Dump the state of this object as a Dictionary.
