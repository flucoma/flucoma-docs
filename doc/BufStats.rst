:digest: Statistically summarise a time series in a Buffer
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulation
:see-also: BufLoudness, BufPitch, BufMelBands, BufMFCC, BufSpectralShape
:description: Statistical analysis on buffer channels.
:discussion: 

  :fluid-obj:`BufStats` statistically summarises a time-series (or any values) that is in a buffer, returning seven statistics for each channel: the buffer channel's mean, standard deviation, skewness, kurtosis, low, middle, and high values. See the ``low``, ``middle`` and ``high`` parameters below for more description on these values.
  
  For a detailed explanation of :fluid-obj:`BufStats` features visit http://learn.flucoma.org/reference/bufstats.

  The ``stats`` output buffer of :fluid-obj:`BufStats` will have the same number of channels as the input buffer, each one containing the statistics of its corresponding channel in the input buffer. Because the dimension of time is summarised statistically, the frames in the ``stats`` buffer do not represent time as they normally would. The first seven frames in every channel of the ``stats`` buffer will have the seven statistics computed on the input buffer channel. After these first seven frames, there will be seven more frames for each derivative requested, each containing the seven statistical summaries for the corresponding derivative.
  
  For example if the input to :fluid-obj:`BufStats` is a three-channel buffer and ``numDerivs`` = 1 the output ``stats`` buffer would contain:
   
   ========= ============ ============= ============= ======== =========== ======== ================= ==================== ===================== ===================== ================ =================== ================
   ch 0 mean ch 0 std dev ch 0 skewness ch 0 kurtosis ch 0 low ch 0 middle ch 0 high ch 0 deriv 1 mean ch 0 deriv 1 std dev ch 0 deriv 1 skewness ch 0 deriv 1 kurtosis ch 0 deriv 1 low ch 0 deriv 1 middle ch 0 deriv 1 high
   ch 1 mean ch 1 std dev ch 1 skewness ch 1 kurtosis ch 1 low ch 1 middle ch 1 high ch 1 deriv 1 mean ch 1 deriv 1 std dev ch 1 deriv 1 skewness ch 1 deriv 1 kurtosis ch 1 deriv 1 low ch 1 deriv 1 middle ch 1 deriv 1 high
   ch 2 mean ch 2 std dev ch 2 skewness ch 2 kurtosis ch 2 low ch 2 middle ch 2 high ch 2 deriv 1 mean ch 2 deriv 1 std dev ch 2 deriv 1 skewness ch 2 deriv 1 kurtosis ch 2 deriv 1 low ch 2 deriv 1 middle ch 2 deriv 1 high
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

   The number of derivatives of the original time-series to compute statistics on. The default of 0 will compute statistics on no derivatives, only the original time-series itself. Setting this parameter > 0 (maximum of 2) will return the same seven statistics computed on consecutive derivatives of the channel's time-series. (``numDerivs`` = 1 will return the channel's statistics and the statistics of the first derivative, ``numDerivs`` = 2 will return the channel's statistics and the statistics of the first and second derivatives.) The derivative statistics are useful to describe the rate of change of the time series.

:control low:

   The value at this percentile (indicated as 0.0-100.0) will be written into frame 4 (zero-counting). By default, it is percentile 0.0, which is the minimum value of the channel.

:control middle:

  The value at this percentile (indicated as 0.0-100.0) will be written into frame 5 (zero-counting). By default, it is percentile 50.0, which is the median value of the channel.

:control high:

  The value at this percentile (indicated as 0.0-100.0) will be written into frame 6 (zero-counting). By default, it is percentile 100.0, which is the maximum value of the channel.

:control outliersCutoff:

   A ratio of the inter quantile range (IQR) that defines a range from the median, outside of which data will be considered an outlier and not used to compute the statistical summary. For each frame, if a single value in any channel of that frame is considered an outlier (when compared to the rest of the values in it's channel), the whole frame (on all channels) will not be used for statistical calculations. The default of -1 bypasses this function, keeping all frames in the statistical measurements.

:control weights:

   A buffer to provide relative weighting of each frame in the ``source`` buffer when computing the statistics. Not providing a ``weights`` buffer will cause all the frames to be considered equally. This may be useful for weighting certain descriptors by the value of other descriptors (such as the loudness or pitch confidence of the sound). The provided buffer has to satisfy all of the following conditions:
  
   * a single-channel
   * exactly the same amount of frames as ``source``
   * all values must be positive (anything lower than 0 will be rejected)

:control select:

   An array of ``symbols`` indicating which statistics to return. The options are ``mean``, ``std``, ``skewness``, ``kurtosis``, ``low``, ``mid``, and ``high``. If nothing is specified, the object will return all the statistics. The statistics will always appear in their normal order, this argument just allows for a selection of them to be returned. Reordering the options in this argument will not reorder how the statistics are returned.