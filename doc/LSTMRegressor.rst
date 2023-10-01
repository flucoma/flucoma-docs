:digest: Series Regression with an LSTM
:species: data
:sc-categories: Machine learning, Regression, LSTM
:sc-related: 
:see-also: LSTMClassifier, LSTMForecast, DataSeries, DataSet
:description: 

   Perform regression between a :fluid-obj:`DataSeries` and a :fluid-obj:`DataSet` using a long-short term memory recurrent neural network (LSTM)

:discussion:  

   For a thorough explanation of how this object works and more information on the parameters, visit the page on **Recurrent Neural Networks** (https://learn.flucoma.org/learn/recurrent-networks).

   Also visit the regression tutorial, this is for the :fluid-obj:`MLPRegressor`, but it is good to understand regression conceptually: (https://learn.flucoma.org/learn/regression-neural-network/)

   Conceptually equivalent to the :fluid-obj:`MLPRegressor`, but where that maps a :fluid-obj:`DataSet` to another, recurrent networks can encode time-based patterns and learn those much more efficiently.

:control hiddenLayers:

   An array of numbers that specifies the internal structure of the neural network. Each number in the list represents one hidden layer of the neural network, the value of which is the number of neurons in that layer. Changing this will reset the neural network, clearing any learning that has happened.

:control maxIter:

   The number of epochs to train for when ``fit`` is called on the object. An epoch consists of training on all the data points one time. Note the the number of epochs will be much lower here than with the MLP objects (try around 5) as every frame in every series is processed.

:control learnRate:

   A scalar for indicating how much the neural network should adjust its internal parameters during training. This is the most important parameter to adjust while training a neural network. 

:control momentum:

   A scalar that applies a portion of previous adjustments to a current adjustment being made by the neural network during training.

:control batchSize:

   The number of data series to use in between adjustments of the LSTM's internal parameters during training.

:control validation:

   A percentage (represented as a decimal) of the data points to randomly select, set aside, and not use for training (this "validation set" is reselected on each ``fit``). These points will be used after each epoch to check how the neural network is performing. If it is found to be no longer improving, training will stop, even if a ``fit`` has not reached its ``maxIter`` number of epochs.

:message fit:

   :arg sourceDataSeries: Source data

   :arg targetDataSet: Target data
   
   Train the network to map between a source :fluid-obj:`DataSeries` and target :fluid-obj:`DataSet`

:message predict:

   :arg sourceDataSeries: Input data

   :arg targetDataSet: Output data

   Apply the learned mapping to a :fluid-obj:`DataSet` (given a trained network)

:message predictSeries:

   :arg sourceBuffer: Input series

   :arg targetBuffer: Output point

   Predict a point for a single data series in a |buffer|

:message clear:

   This will erase all the learning done in the neural network.
