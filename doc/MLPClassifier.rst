:digest: Classification with a multi-layer perceptron
:species: data
:sc-categories: Machine learning
:sc-related: Classes/FluidMLPRegressor, Classes/FluidDataSet, Classes/FluidLabelSet
:see-also: 
:description: 

  Perform classification between a :fluid-obj:`DataSet` and a :fluid-obj:`LabelSet` using a Multi-Layer Perception neural network.
  
  For a thorough explanation of how this object works and more information on the parameters, visit [MLP Training](https://learn.flucoma.org/learn/mlp-training) and [MLP Parameters](https://learn.flucoma.org/learn/mlp-parameters).

:control hidden:

   An ``Classes/Array`` of numbers that specifies the internal structure of the neural network. Each number in the list represents one hidden layer of the neural network, the value of which is the number of neurons in that layer. Changing this will reset the neural network, clearing any learning that has happened.

:control activation:

   An integer indicating which activation function each neuron in the hidden layer(s) will use. Changing this will reset the neural network, clearing any learning that has happened. The options are:
   
   :enum:

      :0:
         **identity** (the output range can be any value)

      :1: 
         **sigmoid** (the output will always range be greater than 0 and less than 1)

      :2: 
         **relu** (the output will always be greater than or equal to 0)

      :3: 
         **tanh** (the output will always be greater than -1 and less than 1) 

:control maxIter:

   The number of epochs to train for when `fit` is called on the object. An epoch is consists of training on all the data points one time.

:control learnRate:

   A scalar for indicating how much the neural network should adjust its internal parameters during training. This is the most important parameter to adjust while training a neural network. Without context, it's difficult to reason about what actual value is most appropriate, however, it can be useful to begin at a relatively high value, such as 0.1, to try to quickly get the neural network in the general area of a solution. Then after a few fittings, decrease the learning rate to a smaller value, maybe 0.01, to slow down the adjustments and let the neural network hone in on a solution. Going as low as 0.0001 is not rare.

:control momentum:

   A scalar that applies a portion of previous adjustments to a current adjustment being made by the neural network during training.

:control batchSize:

   The number of data points to use in between adjustments of the MLP's internal parameters during training.

:control validation:

   A percentage (represented as a decimal) of the data points to randomly select, set aside, and not use for training (this "validation set" is reselected on each ``fit``). Instead these points will be used after each epoch to check how the neural network is performing. If it is found to be no longer improving, training will stop, even if a ``fit`` has not reached its ```maxIter`` number of epochs.

:message fit:

   :arg sourceDataSet: Source data

   :arg targetLabelSet: Target labels

   :arg action: Function to run when training is complete. This function will be passed the current error as its only argument.
   
   Train the network to map between a source :fluid-obj:`DataSet` and target :fluid-obj:`LabelSet`

:message predict:

   :arg sourceDataSet: Input data

   :arg targetLabelSet: :fluid-obj:`LabelSet` to write the predicted labels into

   :arg action: Function to run when complete

   Predict labels for a :fluid-obj:`DataSet` (given a trained network)

:message predictPoint:

   :arg sourceBuffer: Input point

   :arg action: A function to run when complete. This function will be passed the predicted label.

   Predict a label for a single data point in a |buffer|

:message clear:

   :arg action: A function to run when complete

   This will erase all the learning done in the neural network.
