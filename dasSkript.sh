#!/bin/bash
#
# dasSkript.sh
#
# Written by William Ersing
#
# (ext4 version)
#
# This script is used to test the effect of fragmentation
# on read speed for a flash drive using a ext4 file system.
# This file system uses 1K blocks, so in the experiment
# the flash drive is filled with alternating 9K and 1K text
# files. The small (1K) files are then removed, and a much
# larger text file (~11.7M) is copied into the void created
# by their removal. This forces the (very large) file to be
# fragmented as it is written to the flash drive.
#
# Tests are conducted to determine the fragmentation status
# and read speed of the flash drive (both before and after
# it has been fragmented).


# ======================================================
# Prep for the experiment
# ======================================================

readonly MOUNT_POINT="/media/william/flshd"
readonly DEVICE="/dev/sdc1"
nine_kb=""
one_kb=""
i=0
j=1

# Creates content for 9Kb and 1K files
while [ $i -lt 9000 ]
do
    nine_kb+="."
    if [ $i -eq 1000 ]
    then
        one_kb=$nine_kb
    fi
    i=$[$i+1]
done
echo

echo "Formatting flash drive to ext4..."
echo

# Unmount the flash drive
sudo umount $MOUNT_POINT
sleep 1

# Format the flash drive to ext4
sudo mkfs.ext4 $DEVICE
echo
sleep 1

# Mount the flash drive
sudo mount $DEVICE $MOUNT_POINT
sudo chown william:william $MOUNT_POINT
sleep 1


# ======================================================
# Pre-fragmentation testing
# ======================================================

# Copying huge.txt to freshly formatted flash drive
# (used for pre-fragmentation read test)
cp ./huge.txt $MOUNT_POINT"/"

# Pause and wait for user input
read -p "Press [Enter] to test fragmentation status..."
echo

# Check fragmentation status
sudo e2fsck -fn $DEVICE
echo

# Pause and wait for user input
read -p "Press [Enter] to test read speed..."
echo

# Clean RAM (prevents reading from RAM)
sudo /sbin/sysctl vm.drop_caches=3
sleep 1

# Run read speed test
time dd if=$MOUNT_POINT/huge.txt of=/dev/null bs=1K
sleep 1

# Remove huge.txt
rm $MOUNT_POINT/huge.txt
echo

# Pause and wait for user input
read -p "Press [Enter] to begin fragmenting disk..."
echo


# ======================================================
# Fragmenting the flash drive
# ======================================================

# Writes alternating 9Kb and 1Kb files
echo "Writing files to "$MOUNT_POINT
while [ $j -le 10785 ]
do
    if [ `echo "$j % 719" | bc` -eq 0 ]
    then
        echo -n -e "."
    fi
    echo $nine_kb > $MOUNT_POINT"/large_"$j".txt"
    echo $one_kb > $MOUNT_POINT"/small_"$j".txt"
    j=$[$j+1]
done
echo -n -e " Done!"
echo
sleep 1

# Deletes all of the 1Kb files
echo "Deleting small files"
rm $MOUNT_POINT/*small*.txt

# A brief pause to ensure all files delete properly
sleep 2

# Copies huge.txt to flash drive
echo "Copying huge.txt (should fragment on write)"
cp ./huge.txt $MOUNT_POINT"/"
echo


# ======================================================
# Post-fragmentation testing
# ======================================================

# Pause and wait for user input
read -p "Press [Enter] to test fragmentation status..."
echo

# Check fragmentation status
sudo e2fsck -fn $DEVICE
echo

# Pause and wait for user input
read -p "Press [Enter] to test read speed..."
echo

# Clean RAM (prevents reading from RAM)
sudo /sbin/sysctl vm.drop_caches=3
sleep 1

# Run read speed test
time dd if=$MOUNT_POINT/huge.txt of=/dev/null bs=1K
echo
