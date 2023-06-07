# Linux.DebianIsoWithPreseed <img src="https://avatars.githubusercontent.com/u/74443654?s=400&u=482bac7c18c999bfbca7a851489ebbc75cc5e8d0&v=4" width="30" height="30">
This script will create a Debian iso install with preseed configuration. It can then be used to install debian withuot user interaction.  

First check prerequisites

## Debian 11 iso
Next we need to generate a setup file that will be run at server after installation. After running VM you should be able to use ssh without password
Optional: make your changes to the file setup.sh and preseed.cfg

	cd src/LinuxIsoWithPreseed
	bash generate_default.sh
	cd Debian_11
	bash run.sh

Create a Virtual Machine based on the new ISO

## Prerequisites
*xorriso* installed

	sudo apt install xorriso
	sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon

## Build Debian iso installer included preseed config

### About attached preseed.cfg
* Configured for US language and keyboard 
* Use entire disk (/dev/sda)
* Don't create swap partition
* Install base system with ssh-server

## VM build
In folder vm there is an script example that will build vm with Debian preseed ISO

### About attached preseed.cfg
* Configured for US language but with dansih keyboard / locales
* Use entire disk (/dev/sda)
* Don't create swap partition
* Install base system with ssh-server

## Preseed
1. Look at example https://www.debian.org/releases/bullseye/example-preseed.txt
2. Read manual https://www.debian.org/releases/stable/amd64/apb.en.html

### Default preseed 
* Root password = r00tme

### Nice tools
*virt manager* installed
	sudo apt install virt-manager -y

#### Virt Manager (GUI)
Passwordless access

	sudo usermod --append --groups libvirt $(whoami)
