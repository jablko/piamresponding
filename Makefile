.PHONY: all
all: *.img boot rootfs wpa_supplicant.conf piamresponding.exp secure.json
	$(eval loopdev != sudo losetup --find --show --partscan *.img)
	# https://www.raspberrypi.org/documentation/configuration/wireless/headless.md
	sudo mount $(loopdev)p1 boot
	sudo cp wpa_supplicant.conf boot
	sudo umount --lazy boot
	sudo mount $(loopdev)p2 rootfs
	sudo cp /usr/bin/qemu-arm-static rootfs/usr/bin
	sudo chroot rootfs apt-get --assume-yes install \
	  expect \
	  tcllib \
	  tcl-dev \

	sudo rm rootfs/usr/bin/qemu-arm-static
	sudo cp piamresponding.exp secure.json rootfs/home/pi
	sudo mkdir --parents rootfs/home/pi/.config/lxsession/LXDE-pi
	sudo sh -c 'echo "expect piamresponding.exp" > rootfs/home/pi/.config/lxsession/LXDE-pi/autostart'
	sudo chown --recursive 1000:1000 \
	  rootfs/home/pi/piamresponding.exp \
	  rootfs/home/pi/secure.json \
	  rootfs/home/pi/.config \

	sudo umount --lazy rootfs
	sudo losetup --detach $(loopdev)

*.img: raspbian_latest
	unzip -DD raspbian_latest
	# Keep only the newest one
	set $$(ls -t *.img); if [ $$# -gt 1 ]; then shift; rm $$@; fi

# https://www.gnu.org/software/make/manual/make#Interrupts
.PRECIOUS: raspbian_latest
# If there are no prerequisites for a double-colon rule, its recipe is
# always executed (even if the target already exists).
# https://www.gnu.org/software/make/manual/make#Double_002dColon
raspbian_latest::
	wget --no-verbose --continue downloads.raspberrypi.org/$@

boot rootfs:
	mkdir $@
