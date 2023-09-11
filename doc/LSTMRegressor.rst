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

:control hiddenSize:

   Single number that specifies the size of the intermediate recurrent layer network. This roughly equates to how well it can learn complex series, in exchange for model size and training time. Changing this will reset the neural network, clearing any learning that has happened.

:control maxIter:

   The number of epochs to train for when ``fit`` is called on the object. An epoch consists of training on all the data points one time. Note the the number of epochs will be much lower here than with the MLP objects (try around 5) as every frame in every series is processed.

:control learnRate:

   A scalar for indicating how much the neural network should adjust its internal parameters during training. This is the most important parameter to adjust while training a neural network. 

:control batchSize:

   The number of data series to use in between adjustments of the LSTM's internal parameters during training.

:message fit:

   :arg sourceDataSeries: Source data

   :arg targetDataSet: Target data
   
   Train the network to map between a source :fluid-obj:`DataSeries` and target :fluid-obj:`DataSet`

:message predict:

   :arg sourceDataSeries: Input data

   :arg targetDataSet: Output data

   Apply the learned mapping to a :fluid-obj:`DataSet` (given a trained network)

:message predictPoint:

   :arg sourceBuffer: Input series

   :arg targetBuffer: Output point

   Predict a label for a single data point in a |buffer|

:message clear:

   This will erase all the learning done in the neural network.
