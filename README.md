#Fragmentation Test

This script is used to test the effect of fragmentation
on read speed for a flash drive using a ext4 file system.
This file system uses 1K blocks, so in the experiment
the flash drive is filled with alternating 9K and 1K text
files. The small (1K) files are then removed, and a much
larger text file (~11.7M) is copied into the void created
by their removal. This forces the (very large) file to be
fragmented as it is written to the flash drive.

Tests are conducted to determine the fragmentation status
and read speed of the flash drive (both before and after
it has been fragmented).
