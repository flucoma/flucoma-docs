:digest: Computing Statistics on Buffers as Series.
:species: buffer-proc
:sc-categories: Libraries>FluidDecomposition, UGens>Buffer
:sc-related: Guides/FluidCorpusManipulationToolkit
:see-also: BufLoudness, BufPitch, BufMelBands, BufMFCC, BufSpectralShape
:description: Statistical analysis on buffer channels.
:discussion: 
   Typically, a buffer would hold various time series (i.e. descriptors over time), and BufStats allows this series to be described statistically.

   The process returns a buffer where each channel of the source buffer has been reduced to 7 statistics: mean, standard deviation, skewness, kurtosis, followed by 3 percentiles, by default the minimum value, the median, and the maximum value. Moreover, it is possible to request the same 7 stats to be applied to derivative of the input. These are useful to describe statistically the rate of change of the time series. The stats buffer will grow accordingly, yielding the seven same statistical description of the n requested derivatives. Therefore, the stats buffer will have as many channel as the input buffer, and as many frames as 7 times the requested numDerivs (stats of derivatives).

:process: This is the method that calls for the slicing to be calculated on a given source buffer.
:output: Nothing, as the destination buffer is declared in the function call.


:control source:

   The index of the buffer to use as the source material to be processed. The different channels of multichannel buffers will be considered independently as time series.

:control startFrame:

   The starting point (in samples) from which to copy in the source buffer.

:control numFrames:

   The duration (in samples) to copy from the source buffer. The default (-1) copies the full lenght of the buffer.

:control startChan:

   The first channel from which to copy in the source buffer.

:control numChans:

   The number of channels from which to copy in the source buffer. This parameter will wrap around the number of channels in the source buffer. The default (-1) copies all of the buffer's channel.

:control stats:

   The index of the buffer to write the statistics to. Each channel is the fruit of the statistical computations on the same channel number of the source buffer.

:control numDerivs:

   The number of derivatives of the original time series for the statistic to be computed on. By default, none are computed. This will influence the number of frames the stats buffer will have.

:control low:

   The components requested for the first percentile value. By default, it is percentile 0.0, which is the minimum of the given channel of the source buffer.

:control middle:

   The components requested for the second percentile value. By default, it is percentile 50.0, which is the median of the given channel of the source buffer.

:control high:

   The components requested for the third percentile value. By default, it is percentile 100.0, which is the maximum of the given channel of the source buffer.

:control outliersCutoff:

   A ratio of the inter quantile range (IQR) that defines a range outside of which data will be rejected. It is run on each channel independently and a single channel being flagged as outlier removes the whole frame (on all channels). The default (-1) bypasses this function, keeping all frames in the statistical measurements. For more information on this statistical process, please refer to the concept of IQR and how the whiskers of a box plot are computed here (https://en.wikipedia.org/wiki/Box_plot)

:control weights:

   A buffer to provide relative weighting of the source material. Not providing one will not apply weighting and consider all frames equally. The provided buffer has to satisfy all of the following conditions:
  
   * a single-channel, that will be applied to all channels of source;
   * exactly the same amount of frames as ‘source’;
   * weights must be positive (anything lower than 0 will be rejected).

:control action:

   A Function to be evaluated once the offline process has finished and indices instance variables have been updated on the client side. The function will be passed stats as an argument.

