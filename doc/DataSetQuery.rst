:digest: Query a FluidDataSet
:species: data
:sc-categories: UGens>FluidManipulation
:sc-related: Classes/FluidDataSet
:see-also: 
:description: A selection of columns and a set of conditions that match rows of a FluidDataSet. Used to filter and search in a database of descriptors.

:message addColumn:

   :arg column: Column index

   :arg action: Run when done

   Add a column to the query

:message addRange:

   :arg start: First index

   :arg count: Number of columns

   :arg action: Run when done

   Add a range of columns to the query

:message filter:

   :arg column: Column index

   :arg condition: Condition string. Possible values: "==", "!=", "<", "<=", ">", ">="

   :arg value: Condition value

   :arg action: Run when done

   Filter rows according to some condition.

:message and:

   :arg column: Column index

   :arg condition: Condition string. Possible values: "==", "!=", "<", "<=", ">", ">="

   :arg value: Condition value

   :arg action: Run when done

   Add a condition to an existing filter with an "and" connector.

:message or:

   :arg column: Column index

   :arg condition: Condition string. Possible values: "==", "!=", "<", "<=", ">", ">="

   :arg value: Condition value

   :arg action: Run when done

   Add a condition to an existing filter with an "or" connector.

:message limit:

   :arg rows: Maximum number of rows

   :arg action: Run when done

   Limit the number of resulting rows.

:message reset:

   :arg action: Run when done

   Clear the query, remove all columns, filters and limits.

:message transform:

   :arg sourceDataSet: Source data, or the DataSet name

   :arg destDataSet: Destination data, or the DataSet name

   :arg action: Run when done

   Apply the query to a source :fluid-obj:`DataSet` and write to a destination. Can be passed the same for input and output (in-place).

:message transformJoin:

   :arg source1DataSet: Source data, or the DataSet name

   :arg source2DataSet: Source data, or the DataSet name

   :arg destDataSet: Destination data, or the DataSet name

   :arg action: Run when done

   Apply the query to a source FluidDataSet and join the resulting subset at the end of the items sharing the same identifiers in a second source. Items unique to a source dataset will be ignored. To add items at the end of a dataset instead, see the 'merge' method of FluidDataSet.
