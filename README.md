![Foo](/logo.png)
# Linux.DebianIsoWithPreseed
Build a custom debian iso included preseed.cfg based on the current release.

## Prerequisites
* *xorriso* installed \
  `sudo apt install xorriso`

## Build Debian iso installer included preseed config
This script will create a Debian iso install with preseed configuration. It can then be used to install debian withuot user interaction.  
It will download the newest debian and modify iso with your preseed.cfg file

### About attached preseed.cfg
* Configured for US language and keyboard 
* Use entire disk (/dev/sda)
* Don't create swap partition
* Install base system with ssh-server

## VM build example
In folder vm there is an script example that will build vm with Debian preseed ISO

### About attached preseed.cfg
* Configured for US language but with dansih keyboard / locales
* Use entire disk (/dev/sda)
* Don't create swap partition
* Install base system with ssh-server

## preseed
1. Look at example https://www.debian.org/releases/bullseye/example-preseed.txt
2. Read manual https://www.debian.org/releases/stable/amd64/apb.en.html
