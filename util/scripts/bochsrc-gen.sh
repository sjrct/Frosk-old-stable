#!/bin/sh
#
# bashsrc-gen.sh
#
# generates a .bochsrc file for a frosk image
#
# written by sjrct
#

image=frosk.img
output=.bochsrc

hpc=16
spt=63

imgsize=`stat -c%s ${image}`
cyl=$((($imgsize / 512) / ($spt * $hpc)))

if [ $(($imgsize % ($spt * $hpc * 512))) -ne 0 ]
then
	cyl=$(($cyl+1))
fi

echo "ata0: enabled=1, ioaddr1=0x1f0, ioaddr2=0x3f0, irq=14" > $output
echo "ata0-master: type=disk, path=\"./${image}\", mode=flat, cylinders=${cyl}, heads=${hpc}, spt=${spt}, translation=lba" >> $output
echo "config_interface: wx" >> $output
echo "display_library: wx" >> $output
echo "boot: disk" >> $output
echo "log: /dev/stderr" >> $output

