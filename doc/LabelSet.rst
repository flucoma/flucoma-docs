:digest: A set of labels associated with identifiers.
:species: data
:sc-categories: FluidManipulation
:sc-related: Classes/FluidDataSet, Classes/FluidKMeans
:see-also: DataSet, DataSetQuery
:description: FluidLabelSet is a container associating identifiers with labels.


:control name:

   Symbol with the FluidLabelSet name.


:message addLabel:

   :arg identifier: The identifier for this label.

   :arg label: The label to add.

   :arg action: A function to run when the operation completes.

   Add a label to the FluidLabelSet.

:message updateLabel:

   :arg identifier: The identifier for this label.

   :arg label: The label to update.

   Update a label for a given identifier in the label set.

:message setLabel:

   :arg identifier: The identifier for this label.

   :arg label: The label to update.

   Set a label for a given identifier.

:message getLabel:

   :arg identifier: The identifier for the label to be retrieved.

   Retrieve the label associated with an identifier. Will report an error if the identifier is not present in the set.

:message deleteLabel:

   :arg identifier: The identifier to be deleted.

   Delete a label given a certain identifier.

:message clear:

   Empty the label set and reset to a clean state.

:message print:

   Post an abbreviated content of the label set in the window by default, but you can supply a custom action instead.

:message getIds:

   :arg labelSet: The FluidLabelSet to export to. Its content will be replaced.

   :arg action: A function to run when the export is done.

   Export to the dataset identifier to a FluidLabelSet.
