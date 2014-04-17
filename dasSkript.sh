#!/bin/bash
#
# dasSkript.sh
#
# Written by William Ersing
#
# (ext4 version)
#
# A simple script that writes files to a flash drive
# (alternating 9Kb and 1Kb) until the drive is full.
# It then deletes all of the smaller files, and copies
# a very large (approx) 11.7Mb file to the drive. This
# last write should wind up as a very fragmented file.

i=0
j=0
k=1
nine_kb=""
one_kb=""
mount_point="/media/william/flshd"
device="/dev/sdc1"

# Creates content for 9Kb files
while [ $i -lt 9000 ]
do
	nine_kb+="."
	i=$[$i+1]
done

# Creates content for 1Kb files
while [ $j -lt 1000 ]
do
	one_kb+="."
	j=$[$j+1]
done

echo
echo "Formatting flash drive to ext4..."
echo

# Unmount the flash drive
sudo umount $mount_point; sleep 1

# Format the flash drive to ext4
sudo mkfs.ext4 $device

# Mount the flash drive
sudo mount $device $mount_point
sudo chown william:william $mount_point

# Copying huge.txt to freshly formatted flash drive
# (used for pre-fragmentation read test)
cp ./huge.txt $mount_point"/"

# Pause and wait for user input
read -p "Press [Enter] to test fragmentation status..."
echo

# Check fragmentation status
sudo e2fsck -fn $device
echo

# Pause and wait for user input
read -p "Press [Enter] to test read speed..."
echo

# Clean RAM (prevents reading from RAM)
sudo /sbin/sysctl vm.drop_caches=3
sleep 1

# Run read speed test
time dd if=$mount_point/huge.txt of=/dev/null bs=1K

# Remove huge.txt
rm $mount_point/huge.txt
echo

# Pause and wait for user input
read -p "Press [Enter] to begin fragmenting disk..."
echo

# Writes alternating 9Kb and 1Kb files
echo "Writing files to "$mount_point
while [ $k -le 10785 ]
do
	if [ `echo "$k % 719" | bc` -eq 0 ]
	then
		echo -n -e "."
	fi
	echo $nine_kb > $mount_point"/large_"$k".txt"
	echo $one_kb > $mount_point"/small_"$k".txt"
	k=$[$k+1]
done
echo -n -e " Done!"
echo

# Deletes all of the 1Kb files
echo "Deleting small files"
rm $mount_point/*small*.txt

# A brief pause to ensure all files delete properly
sleep 2

# Copies huge.txt to flash drive
echo "Copying huge.txt (should fragment on write)"
cp ./huge.txt $mount_point"/"
echo


# ======================================================
# Post-fragmentation testing
# ======================================================

# Pause and wait for user input
read -p "Press [Enter] to test fragmentation status..."
echo

# Check fragmentation status
sudo e2fsck -fn $device

# Pause and wait for user input
read -p "Press [Enter] to test read speed..."
echo

# Clean RAM (prevents reading from RAM)
sudo /sbin/sysctl vm.drop_caches=3
sleep 1

# Run read speed test
time dd if=$mount_point/huge.txt of=/dev/null bs=1K

