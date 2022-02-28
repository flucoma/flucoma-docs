:digest: Constrain a 2D DataSet into a Grid.
:species: data
:sc-categories: Dimensionality Reduction, Data Processing
:sc-related: Classes/FluidMDS, Classes/FluidPCA, Classes/FluidUMAP, Classes/FluidDataSet
:see-also: UMAP, MDS, PCA, DataSet
:description: Maps a set of 2D points in a :fluid-obj:`DataSet` to a rectangular grid.
:discussion: 
   :fluid-obj:`Grid` transforms a two-dimensional dataset into a grid using a variant of the Jonker-Volgenant algorithm (https://www.gwern.net/docs/statistics/decision/1987-jonker.pdf). This can be useful to generate compact grid layouts from the output of dimensionality reduction algorithms such as :fluid-obj:`UMAP`, :fluid-obj:`PCA` or :fluid-obj:`MDS` and for making uniformally distributed spaces out of any two-dimensional dataset.

   This approach is similar to projects like CloudToGrid (https://github.com/kylemcdonald/CloudToGrid/), RasterFairy (https://github.com/Quasimondo/RasterFairy) or IsoMatch (https://github.com/ohadf/isomatch).



:control oversample:

   A factor to oversample the destination grid. The default is 1, so the grid has the same number of points as the input. Factors of 2 or more will allow a larger destination grid, which will respect the original shape a little more, but will also be sparser.

:control extent:

   The size to which the selected axis will be constrained. The default is 0, which turns the constraints off.

:control axis:

   The axis to which the extent constraint is applied. The default 0 is horizontal, and 1 is vertical.


:message fitTransform:

   :arg sourceDataSet: Source data, or the DataSet name

   :arg destDataSet: Destination data, or the DataSet name

   :arg action: Run when done

   Fit the model to a :fluid-obj:`DataSet` and write the new projected data to a destination FluidDataSet.
