:digest: Series Classification with an LSTM
:species: data
:sc-categories: Machine learning, Classification, LSTM
:sc-related: 
:see-also: LSTMRegressor, LSTMForecast, DataSeries, LabelSet
:description: 

  Perform classification between a :fluid-obj:`DataSeries` and a :fluid-obj:`LabelSet` using a long-short term memory recurrent neural network (LSTM)

:discussion:  

   For a thorough explanation of how this object works and more information on the parameters, visit the page on **Recurrent Neural Networks** (https://learn.flucoma.org/learn/recurrent-networks).

   Also visit the classification tutorial, this is for the :fluid-obj:`MLPRegressor`, but it is good to understand regression conceptually: (https://learn.flucoma.org/learn/classification-neural-network/)

   Conceptually equivalent to the :fluid-obj:`MLPClassifier`, but where that maps a :fluid-obj:`DataSet` to a :fluid-obj:`LabelSet`, recurrent networks can encode time-based patterns and learn those much more efficiently, so map a :fluid-obj:`DataSeries` to a :fluid-obj:`LabelSet`

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

   :arg targetLabelSet: Target labels
   
   Train the network to map between a source :fluid-obj:`DataSeries` and target :fluid-obj:`LabelSet`

:message predict:

   :arg sourceDataSeries: Input data

   :arg targetLabelSet: :fluid-obj:`LabelSet` to write the predicted labels into

   Predict labels for a :fluid-obj:`DataSeries` (given a trained network)

:message predictSeries:

   :arg sourceBuffer: Input series

   Predict a label for a single data series in a |buffer|

:message clear:

   This will erase all the learning done in the neural network.