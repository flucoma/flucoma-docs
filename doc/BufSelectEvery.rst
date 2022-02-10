:digest: Extract every N samples / channels from a buffer
:species: buffer-proc
:sc-categories: FluidCorpusManipulation
:sc-related: Classes/Buffer
:see-also: BufSelect
:description: Pick every N frames and / or channels from a buffer, described in terms of independent hop sizes for frames and channels


:control source:

   The |buffer| to pick values from

:control startFrame:

   The starting point (in samples) from which to copy in the source buffer.

:control numFrames:

   The duration (in samples) to copy from the source buffer. The default (-1) copies the full length of the buffer.

:control startChan:

   The first channel from which to copy in the source buffer.

:control numChans:

   The number of channels from which to copy in the source buffer.

:control destination:

   The |buffer| to write the selected data to

:control frameHop:

   Take every ``frameHop`` frames. Default = 1 = all frames (where 2 would be every other frame, etc.)

:control chanHop:

   Take every ``chanHop`` channels. Default = 1 = all channels (where 2 would be every other channel, etc.)

