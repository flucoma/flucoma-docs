:digest: Regression with a multi-layer perceptron
:species: data
:sc-categories: Machine learning
:sc-related: Classes/FluidMLPClassifier, Classes/FluidDataSet
:see-also: 
:description: Perform regression between :fluid-obj:`DataSet`\s using a Multi-Layer Perception neural network.


:control hidden:

   An `Classes/Array` that gives the sizes of any hidden layers in the network (default is two hidden layers of three units each).

:control activation:

   The activation function to use for the hidden layer units. Beware of the permitted ranges of each: relu (0->inf), sigmoid (0->1), tanh (-1,1)

:control outputActivation:

   The activation function to use for the output layer units. Beware of the permitted ranges of each: relu (0->inf), sigmoid (0->1), tanh (-1,1)

:control tapIn:

   The layer whose input is used to predict and predictPoint. It is 0 counting, where the default of 0 is the input layer, and 1 would be the first hidden layer, and so on.

:control tapOut:

   The layer whose output to return. It is counting from 0 as the input layer, and 1 would be the first hidden layer, and so on. The default of -1 is the last layer of the whole network.

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

   :arg targetDataSet: Target data

   :arg action: Function to run when training is complete

   Train the network to map between a source and target :fluid-obj:`DataSet`

:message predict:

   :arg sourceDataSet: Input data

   :arg targetDataSet: Output data

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
