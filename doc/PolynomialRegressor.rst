:digest: Polynomial regression on data sets.
:species: data
:sc-categories: Statistical regression
:sc-related: 
:see-also: DataSet
:description: 

    Perform regression between <o>fluid.dataset</o>\s using N parallel 1-to-1 polynomial regressors in one object.

:discussion:

    A polynomial regressor is a very simple algorithm that, given a set of input-output pairs - :math:`x` to :math`y`, for example - will find the line of best fit for that data. Linear regression is a special case when the ``degree`` of the polynomial is ``1``, meaning the highest power of :math:`x` fitted is ``1`` (it find the best :math`y = mx + c` to fit the data)
    Essentially, each element of each input is mapped to the corresponding element of the same output, hence it needing to be an N-to-N corpus, which is one limitation of this algorithm.
    Tikhonov regularisation is an improvement of this algorithm, which compensates for noisy data and reduces overfitting in certain situations, a good explanation of how this works can be found on wikipedia (https://en.wikipedia.org/wiki/Ridge_regression#Tikhonov_regularization)

:control degree:

    An integer that specifies the degree \(highest power of x\) that the fit polynomial will have; e.g. a degree of 2 means that the polynomial will have a form :math:`y = \alpha + \beta x + \gamma x^2`

:control tikhonov:

    A floating point value that describes the strength of the Tikhonov filter, namely how much the algorithm is penalised for overfitting to the data

:message fit:

   :arg sourceDataSet: Source data

   :arg targetDataSet: Target data
   
   Fit the polynomial to map between a source and target :fluid-obj:`DataSet`

:message predict:

   :arg sourceDataSet: Input :fluid-obj:`DataSet`

   :arg targetDataSet: Output :fluid-obj:`DataSet`

   Apply the regressed mapping to a :fluid-obj:`DataSet` and predict the output value for each point

:message predictPoint:

   :arg sourceBuffer: Input point

   :arg targetBuffer: Output point

   Apply the regressed mapping to a single data point in a |buffer|

:message clear:

   This will erase all the learned polynomials.

:message print:

    Print object information to the console.

:message read:

    :arg fileName: file to read from (optional, will prompt if not present)

    load regressed polynomials from a json file on disk

:message write:

    :arg fileName: file to write to (optional, will prompt if not present)

    write current regression to a json file on disk
