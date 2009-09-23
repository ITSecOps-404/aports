#!/bin/sh

for i in "$@"; do
	# get last element in path
	flavor=${i##*/}
	abi_release=$(cat "$i"/kernel.release)
	initfs=initramfs-$abi_release
	mkinitfs -o /boot/$initfs $abi_release
	ln -sf $initfs /boot/initramfs-$flavor
	ln -sf vmlinuz-$abi_release /boot/vmlinuz-$flavor

	# extlinux will use path relative partition, so if /boot is on a
	# separate partition we want /boot/<kernel> resolve to /<kernel>
	ln -sf / /boot/boot

	#this is for compat. to be removed eventually...
	ln -sf vmlinuz-$flavor /boot/$flavor
	ln -sf initramfs-$flavor /boot/$flavor.gz
	ln -sf /boot/vmlinuz-$flavor /$flavor
	ln -sf /boot/initramfs-$flavor /$flavor.gz

	# Update the /boot/extlinux.conf to point to correct kernel
	f=/boot/extlinux.conf
	if [ -f $f ] && grep -q -- "kernel /$flavor" $f; then
		sed -i -e "s:kernel /$flavor:kernel /boot/vmlinuz-$flavor:" \
		  -e "s:initrd=/$flavor.gz:initrd=/boot/initramfs-$flavor:" \
		  -e "s:initrd /$flavor.gz:initrd /boot/initramfs-$flavor:" \
		  $f
	fi
done

