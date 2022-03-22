:digest: Statistically summarise a time series in a Buffer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufLoudness, BufPitch, BufMelBands, BufMFCC, BufSpectralShape
:description: Statistical analysis on buffer channels.
:discussion: 

   A buffer typically holds time-series information as "frames," either in the form of audio samples (as an audio buffer for playback) or as a series of audio descriptors created by an analysis process (as is the case with FluCoMa's buffer-based analyses). :fluid-obj:`BufStats` statistically summarises a time-series that is in a buffer, returning seven statistical properties for each channel: the buffer channel's mean, standard deviation, skewness, kurtosis, minimum, median, and maximum values.

   Setting the parameter ``numDerivs`` > 0 will return the same seven statistics computed on consecutive derivatives of the channel's time-series. (``numDerivs`` = 1 will return the channel's statistics and the statistics of the first derivative, ``numDerivs`` = 2 will return the channel's statistics and the statistics of the first and second derivatives, etc.) The derivative statistics are useful to describe the rate of change of the time series. 
 
   The ``stats`` output buffer of :fluid-obj:`BufStats` will have the same number of channels as the input buffer, each one containing the statistics of it's corresponding channel in the input buffer. Because the dimension of time is summarised statistically, the frames in the ``stats`` buffer do not represent time as they normally would. The first seven frames in every channel of the ``stats`` buffer will have the seven statistics computed on the input buffer channel. After these first seven frames, there will be seven more frames for each derivative requested, each containing the seven statistical summaries for the corresponding derivative.
   
   For example if the input to :fluid-obj:`BufStats` is a three-channel buffer and ``numDerivs`` = 1 the output ``stats`` buffer would contain:
   
   ========= ============ ============= ============= ======== =========== ======== ================= ==================== ===================== ===================== ================ =================== ================
   ch 0 mean ch 0 std dev ch 0 skewness ch 0 kurtosis ch 0 min ch 0 median ch 0 max ch 0 deriv 1 mean ch 0 deriv 1 std dev ch 0 deriv 1 skewness ch 0 deriv 1 kurtosis ch 0 deriv 1 min ch 0 deriv 1 median ch 0 deriv 1 max
   ch 1 mean ch 1 std dev ch 1 skewness ch 1 kurtosis ch 1 min ch 1 median ch 1 max ch 1 deriv 1 mean ch 1 deriv 1 std dev ch 1 deriv 1 skewness ch 1 deriv 1 kurtosis ch 1 deriv 1 min ch 1 deriv 1 median ch 1 deriv 1 max
   ch 2 mean ch 2 std dev ch 2 skewness ch 2 kurtosis ch 2 min ch 2 median ch 2 max ch 2 deriv 1 mean ch 2 deriv 1 std dev ch 2 deriv 1 skewness ch 2 deriv 1 kurtosis ch 2 deriv 1 min ch 2 deriv 1 median ch 2 deriv 1 max
   ========= ============ ============= ============= ======== =========== ======== ================= ==================== ===================== ===================== ================ =================== ================    

:process: This is the method that calls for the statistical analysis to be calculated on ``source``.

:output: Nothing, as the ``stats`` buffer is declared in the function call.

:control source:

   The buffer to statistically summarise. Each channel of multichannel buffers will be computed independently.

:control startFrame:

   The position (in frames) to begin the statistical analysis. :fluid-obj:`BufStats` is unaware of what kind of time-series is in ``source`` and what the sample rate might be (whether it is audio samples or audio descriptors). It will begin analysis at the indicated frame index in ``source``. The default is 0.

:control numFrames:

   The number of frames to use in the statistical analysis. The default of -1 indicates to use all the frames from ``startFrame`` through the end of the ``source`` buffer.

:control startChan:

   The channel from which to begin computing statistics for. The default is 0.

:control numChans:

   The number of channels to compute statistics for. The default of -1 indicates to compute statistics through the last channel in the ``source`` buffer.

:control stats:

   The buffer to write the statistical summary into.

:control numDerivs:

   The number of derivatives of the original time-series to compute statistics on. The default of 0 will compute statistics on no derivates, only the original time-series itself.

:control low:

   The value at this percentile (indicated as 0.0-100.0) will be written into frame 4 (zero-counting). By default, it is percentile 0.0, which is the minimum value of the channel.

:control middle:

  The value at this percentile (indicated as 0.0-100.0) will be written into frame 5 (zero-counting). By default, it is percentile 50.0, which is the median value of the channel.

:control high:

  The value at this percentile (indicated as 0.0-100.0) will be written into frame 6 (zero-counting). By default, it is percentile 100.0, which is the maximum value of the channel.

:control outliersCutoff:

   A ratio of the inter quantile range (IQR) that defines a range from the median, outside of which data will be considered an outlier and not used to compute the statistical summary. For each frame, if a single value in any channel of that frame is considered an outlier (when compared to the rest of the values in it's channel), the whole frame (on all channels) will not be used for statistical calculations. The default of -1 bypasses this function, keeping all frames in the statistical measurements. For more information on this statistical process, please refer to the concept of inter quantile range IQR and how the whiskers of a box plot are computed here (https://en.wikipedia.org/wiki/Box_plot)

:control weights:

   A buffer to provide relative weighting of each frame in the ``source`` buffer when computing the statistics. Not providing a ``weights`` buffer will cause all the frames to be considered equally. This may be useful for weighting certain descriptors by the loudness or pitch confidence of the sound in a buffer. The provided buffer has to satisfy all of the following conditions:
  
   * a single-channel
   * exactly the same amount of frames as ``source``
   * all values must be positive (anything lower than 0 will be rejected)

:control action:

   A Function to be evaluated once the offline process has finished and all the |buffer| variables have been updated on the client side. The function will be passed ``stats`` as an argument.
