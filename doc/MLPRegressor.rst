:digest: Regression with a multi-layer perceptron
:species: data
:sc-categories: Machine learning
:sc-related: 
:see-also: KNNRegressor, DataSet, MLPClassifier
:description: 

  Perform regression between :fluid-obj:`DataSet`\s using a Multi-Layer Perceptron neural network.

:discussion:

  For a thorough explanation of how this object works and more information on the parameters, visit the page on **MLP Training** (https://learn.flucoma.org/learn/mlp-training) and **MLP Parameters** (https://learn.flucoma.org/learn/mlp-parameters).

  Also visit the regression tutorial: (https://learn.flucoma.org/learn/classification-neural-network/)

:control hiddenLayers:

   An array of numbers that specifies the internal structure of the neural network. Each number in the list represents one hidden layer of the neural network, the value of which is the number of neurons in that layer. Changing this will reset the neural network, clearing any learning that has happened.

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

:control outputActivation:

   An integer indicating which activation function each neuron in the output layer will use. Options are the same as ``activation``. Changing this will reset the neural network, clearing any learning that has happened.

:control tapIn:

   The index of the layer to use as input to the neural network for ``predict`` and ``predictPoint`` (zero counting). The default of 0 is the first layer (the original input layer), 1 is the first hidden layer, etc. This can be used to access different parts of a trained neural network such as the encoder or decoder of an autoencoder (https://towardsdatascience.com/auto-encoder-what-is-it-and-what-is-it-used-for-part-1-3e5c6f017726).

:control tapOut:

   The index of the layer to use as output of the neural network for ``predict`` and ``predictPoint`` (zero counting). The default of -1 is the last layer (the original output layer). This can be used to access different parts of a trained neural network such as the encoder or decoder of an autoencoder (https://towardsdatascience.com/auto-encoder-what-is-it-and-what-is-it-used-for-part-1-3e5c6f017726).

:control maxIter:

   The number of epochs to train for when ``fit`` is called on the object. An epoch consists of training on all the data points one time.

:control learnRate:

   A scalar for indicating how much the neural network should adjust its internal parameters during training. This is the most important parameter to adjust while training a neural network. 

:control momentum:

   A scalar that applies a portion of previous adjustments to a current adjustment being made by the neural network during training.

:control batchSize:

   The number of data points to use in between adjustments of the MLP's internal parameters during training.

:control validation:

   A percentage (represented as a decimal) of the data points to randomly select, set aside, and not use for training (this "validation set" is reselected on each ``fit``). These points will be used after each epoch to check how the neural network is performing. If it is found to be no longer improving, training will stop, even if a ``fit`` has not reached its ```maxIter`` number of epochs.

:message fit:

   :arg sourceDataSet: Source data

   :arg targetDataSet: Target data

   :arg action: Function to run when complete. This function will be passed the current error as its only argument.
   
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
