:digest: A set of labels associated with identifiers.
:species: data
:sc-categories: FluidManipulation
:sc-related: Classes/Dictionary
:see-also: DataSet, DataSetQuery, KMeans
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

   Export the LabelSet identifier to a FluidLabelSet.

:message merge:

   :arg sourceLabelSet: The source LabelSet to be merged.

   :arg overwrite: A flag to allow overwrite labels with the same identifier.

   Merge sourceLabelSet in the current LabelSet. It will replace the label with the same identifier if overwrite is set to 1.

:message write:

   Save the contents of the object to a JSON file on disk.

:message dump:

   Dump the state of this object as a Dictionary.
