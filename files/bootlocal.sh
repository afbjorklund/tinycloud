#!/bin/sh
# put other system startup commands here

test -e /usr/local/etc/ssh/ssh_config || cp /usr/local/etc/ssh/ssh_config.orig /usr/local/etc/ssh/ssh_config
test -e /usr/local/etc/ssh/sshd_config || cp /usr/local/etc/ssh/sshd_config.orig /usr/local/etc/ssh/sshd_config
if ! grep -q "^PasswordAuthentication" /usr/local/etc/ssh/sshd_config; then
	echo "PasswordAuthentication no" >>/usr/local/etc/ssh/sshd_config
fi
for keyType in rsa dsa ecdsa ed25519; do # pre-generate a few SSH host keys to decrease the verbosity of /usr/local/etc/init.d/openssh
	keyFile="/usr/local/etc/ssh/ssh_host_${keyType}_key"
	[ ! -f "$keyFile" ] || continue
	echo "Generating $keyFile"
	ssh-keygen -q -t "$keyType" -N '' -f "$keyFile"
done
/usr/local/etc/init.d/openssh start

test ! -L /usr/local/etc/fuse.conf || mv /usr/local/etc/fuse.conf /usr/local/etc/fuse.conf.orig
test -e /usr/local/etc/fuse.conf || cp /usr/local/etc/fuse.conf.orig /usr/local/etc/fuse.conf
if ! grep -q "^user_allow_other" /usr/local/etc/fuse.conf; then
	echo "user_allow_other" >>/usr/local/etc/fuse.conf
fi

/opt/tinycloudinit.sh

cp /mnt/lima-cidata/meta-data /run/lima-ssh-ready
cp /mnt/lima-cidata/meta-data /run/lima-boot-done
