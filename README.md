# Fragmentation Experiment

This script was used in an experiment to test the affect
of File System fragmentation on disk read/write speeds.

The experiment was conducted on an ext4 formated flash
drive with 1K blocks. Given the 1K block size, the flash
drive was filled with alternating 9K and 1K text
files. Once the disc was full, all small files (1K) were
removed to create many non-contiguous empty spaces.
At that point, a much larger text file (~11.7M) was
copied onto the flash drive with the expectation that the
data would be fragmented across the scattered free space.

Tests were conducted to determine total disc fragmentation.
Disc read and write speeds were tested before and after
fragmentation to compare results and form a conclusion.

Unsurprisingly, read and write speeds were noticeably slower
on the fragmented file system.
