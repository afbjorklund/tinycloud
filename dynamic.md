
====== Introduction ======

The method described here allows you to modify the root filesystem of a TC/MC system without actually modifying the tinycore.gz/microcore.gz files. This is particularly useful when you want your remaster to work with a new version of TC/MC or if you for some other reason want to remaster the root filesystem without having to modify the root filesystem files shipped by TC/MC.

The method is based on the capability of the syslinux family bootloaders (syslinux, isolinux, extlinux, pxelinux) to load multiple initramfs images during boot. If you are using Grub you could still use this method by chainloading from Grub to a syslinux family bootloader.

The description here is based on the use of extlinux (since I use this to boot from an ext2 partition), however the same configuration should be possible to use for other syslinux family bootloaders.

====== Install extlinux ======

In order to install extlinux to your boot partition you need have the TC ''syslinux.tcz'' extension installed on your system and the boot partition mounted. My boot partition is mounted under ''/mnt/hda1'' and I install extlinux at ''/mnt/hda1/boot/extlinux''.

To install extlinux you do:

<code>sudo extlinux -i /mnt/hda1/boot/extlinux</code>

This will make the file ''extlinux.sys'' appear in the installation directory. (Mount the device manually: "mount /dev/xxx /mnt/xxx". Using the mount tool provided by tinycore extlinux will give you an error (it can't install to devices mounted with loop).

====== Configure extlinux ======

extlinux operates according to a configuration file called ''extlinux.conf'' and this file should be located in the extlinux installation directory (''/mnt/hda1/boot/extlinux'').

The content of this file should look something like:
<code>
default vesamenu.c32

menu title My Boot Options

timeout 200

prompt 0

ontimeout mc_original

label my_remaster
	menu label Microcore with remaster
	kernel /boot/vmlinuz
	initrd /boot/core.gz,/boot/my_initramfs.gz
	append base

label mc_original
	menu label Microcore without remaster
	kernel /boot/vmlinuz
	initrd /boot/core.gz
	append base


menu width 80
menu margin 10
menu rows 12
menu tabmsgrow 18
menu endrow 24
menu timeoutrow 20
</code>

The core part for the remaster function is the line:

<code>	initrd /boot/core.gz,/boot/my_initramfs.gz</code>

This tells extlinux to load both ''core.gz'' AND ''my_initramfs.gz'' and create a root file system that is the combination of the two.

====== Create remaster content ======

The remaster content should be packed into a gzipped cpio archive. What it should contain is up to you. We here show an example where a couple of TC/MC extensions are placed at ''/opt/tce/optional''. During startup TC/MC will load any extension found in the list ''/opt/tce/onboot.lst''.

First you need to create a working directory that represents the root of the initramfs to be created:

<code>$ mkdir my_root
$ cd my_root</code>

Now create the directory where the extensions are going and copy the extensions to that directory:

<code>$ mkdir -p opt/tce/optional
$ cp /path_to_extensions/xxx.tcz  opt/tce/optional
$ cp /path_to_extensions/yyy.tcz  opt/tce/optional
$       .
$       .
$ ls -1 opt/tce/optional > opt/tce/onboot.lst
</code>

Once all files to be included into the root filesystem are in place, it is time to create the archive and copy it to the boot partition.

|<code>$ find | sudo cpio -o -H newc | gzip > ../my_initramfs.gz|
$ sudo cp ../my_initramfs.gz /mnt/hda1/boot
</code>

---

Adopted from the Tiny Core Linux wiki:
> [wiki/dynamic_root_filesystem_remastering](https://wiki.tinycorelinux.net/doku.php?id=wiki:dynamic_root_filesystem_remastering) . Last modified: 2013/01/04 16:57 by BobBagwill
>
> Except where otherwise noted, content on this wiki is licensed under the following license: [CC Attribution-Share Alike 3.0 Unported](http://creativecommons.org/licenses/by-sa/3.0/)
