:digest: Series Classification with an LSTM
:species: data
:sc-categories: Machine learning, Classification, LSTM
:sc-related: 
:see-also: LSTMRegressor, LSTMForecast, DataSeries, LabelSet
:description: 

  Perform classification between a :fluid-obj:`DataSeries` and a :fluid-obj:`LabelSet` using a long-short term memory recurrent neural network (LSTM)

:discussion:  

   For a thorough explanation of how this object works and more information on the parameters, visit the page on **MLP Training** (https://learn.flucoma.org/learn/mlp-training) and **MLP Parameters** (https://learn.flucoma.org/learn/mlp-parameters).

   Also visit the classification tutorial, this is for the :fluid-obj:`MLPRegressor`, but it is good to understand regression conceptually: (https://learn.flucoma.org/learn/classification-neural-network/)

   Conceptually equivalent to the :fluid-obj:`MLPClassifier`, but where that maps a :fluid-obj:`DataSet` to another, recurrent networks can encode time-based patterns and learn those much more efficiently, so map a :fluid-obj:`DataSeries` to a :fluid-obj:`DataSet`

:control hiddenSize:

   An array of numbers that specifies the internal structure of the neural network. Each number in the list represents one hidden layer of the neural network, the value of which is the number of neurons in that layer. Changing this will reset the neural network, clearing any learning that has happened.

:control maxIter:

   The number of epochs to train for when ``fit`` is called on the object. An epoch consists of training on all the data points one time. Note the the number of epochs will be much lower here than with the MLP objects (try around 5)

:control learnRate:

   A scalar for indicating how much the neural network should adjust its internal parameters during training. This is the most important parameter to adjust while training a neural network. 

:control batchSize:

   The number of data points to use in between adjustments of the LSTM's internal parameters during training.

:message fit:

   :arg sourceDataSeries: Source data

   :arg targetLabelSet: Target labels
   
   Train the network to map between a source :fluid-obj:`DataSeries` and target :fluid-obj:`LabelSet`

:message predict:

   :arg sourceDataSeries: Input data

   :arg targetLabelSet: :fluid-obj:`LabelSet` to write the predicted labels into

   Predict labels for a :fluid-obj:`DataSeries` (given a trained network)

:message predictPoint:

   :arg sourceBuffer: Input point

   Predict a label for a single data point in a |buffer|

:message clear:

   This will erase all the learning done in the neural network.