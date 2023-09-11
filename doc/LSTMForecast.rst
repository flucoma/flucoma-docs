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

:control hiddenSize:

   Single number that specifies the size of the intermediate recurrent layer network. This roughly equates to how well it can learn complex series, in exchange for model size and training time. Changing this will reset the neural network, clearing any learning that has happened.

:control maxIter:

   The number of epochs to train for when ``fit`` is called on the object. An epoch consists of training on all the data points one time. Note every frame is processed so the the number of epochs will be much lower here than with the MLP objects (try around 5)

:control learnRate:

   A scalar for indicating how much the neural network should adjust its internal parameters during training. This is the most important parameter to adjust while training a neural network. 

:control batchSize:

   The number of data series to use in between adjustments of the LSTM's internal parameters during training.

:message fit:

   :arg sourceDataSeries: Source data
   
   Train the network to learn to continue a :fluid-obj:`DataSeries`

:message predict:

   :arg sourceDataSeries: Input data

   :arg targetDataSeries: Where to output the forecasted data

   :arg forecastLength: how many frames to predict into the future, if left blank it will return the same number of frames provided for each series

   Predict continuations for a :fluid-obj:`DataSeries` (given a trained network)

:message predictPoint:

   :arg sourceBuffer: Input series

   :arg targetBuffer: Where to output the forecasted data

   :arg forecastLength: how many frames to predict into the future, if left blank it will return the same number of frames provided

   Predict a continuation to the data in a |buffer| (given a trained network)

:message clear:

   This will erase all the learning done in the neural network.