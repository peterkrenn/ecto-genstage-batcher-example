# Ecto GenStage Batcher Example

This is an example how to use **GenStage** to collect _SELECT_ queries from many
long-running processes within an interval into batches which are processed
with `ConsumerSupervisor`.
