:digest: Series Forecasting with an LSTM
:species: data
:sc-categories: Machine Learning, LSTM, Prediction
:sc-related: 
:see-also: LSTMClassifier, LSTMRegressor, DataSeries
:description: 

   Predict/forecast a continuation to an input :fluid-obj:`DataSeries` using a long-short term memory recurrent neural network (LSTM)

:discussion:

   For a thorough explanation of how this object works and more information on the parameters, visit the page on **Recurrent Neural Networks** (https://learn.flucoma.org/learn/recurrent-networks).

   This object is not like anything that has been seen yet - it takes a single :fluid-obj:`DataSeries` and learns to predict continuations to the series with the same 'style'. It is currently rather limited in its ability, but will recieve improvements in predicting ability in the future!

:control hiddenLayers:

   An array of numbers that specifies the internal structure of the neural network. Each number in the list represents one hidden layer of the neural network, the value of which is the number of neurons in that layer. Changing this will reset the neural network, clearing any learning that has happened.

:control maxIter:

   The number of epochs to train for when ``fit`` is called on the object. An epoch consists of training on all the data points one time. Note every frame is processed so the the number of epochs will be much lower here than with the MLP objects (try around 5)

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
   
   Train the network to learn to continue a :fluid-obj:`DataSeries`

:message predict:

   :arg sourceDataSeries: Input data

   :arg targetDataSeries: Where to output the forecasted data

   :arg forecastLength: how many frames to predict into the future, if left blank it will return the same number of frames provided for each series

   Predict continuations for a :fluid-obj:`DataSeries` (given a trained network)

:message predictSeries:

   :arg sourceBuffer: Input series

   :arg targetBuffer: Where to output the forecasted data

   :arg forecastLength: how many frames to predict into the future, if left blank it will return the same number of frames provided

   Predict a continuation to the data in a |buffer| (given a trained network)

:message clear:

   This will erase all the learning done in the neural network.