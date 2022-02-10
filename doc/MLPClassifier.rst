:digest: Classification with a multi-layer perceptron
:species: data
:sc-categories: Machine learning
:sc-related: Classes/FluidMLPRegressor, Classes/FluidDataSet
:see-also: 
:description: Perform classification between a :fluid-obj:`DataSet` and a :fluid-obj:`LabelSet` using a Multi-Layer Perception neural network.


:control hidden:

   An ``Classes/Array`` that gives the sizes of any hidden layers in the network (default is two hidden layers of three units each).

:control activation:

   The activation function to use for the hidden layer units. Beware of the permitted ranges of each: relu (0->inf), sigmoid (0->1), tanh (-1,1).

:control maxIter:

   The maximum number of iterations to use in training.

:control learnRate:

   The learning rate of the network. Start small, increase slowly.

:control momentum:

   The training momentum, default 0.9

:control batchSize:

   The training batch size.

:control validation:

   The fraction of the DataSet size to hold back during training to validate the network against.


:message fit:

   :arg sourceDataSet: Source data

   :arg targetLabelSet: Target data

   :arg action: Function to run when training is complete

   Train the network to map between a source :fluid-obj:`DataSet` and a target :fluid-obj:`LabelSet`

:message predict:

   :arg sourceDataSet: Input data

   :arg targetLabelSet: Output data

   :arg action: Function to run when complete

   Apply the learned mapping to a :fluid-obj:`DataSet` (given a trained network)

:message predictPoint:

   :arg sourceBuffer: Input point

   :arg targetBuffer: Output point

   :arg action: A function to run when complete

   Apply the learned mapping to a single data point in a |buffer|

:message clear:

   :arg action: A function to run when complete

   This will erase all the learning done in the neural network.
