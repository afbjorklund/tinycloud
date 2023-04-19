#!/bin/sh
# put other system startup commands here

test -e /usr/local/etc/ssh/ssh_config || cp /usr/local/etc/ssh/ssh_config.orig /usr/local/etc/ssh/ssh_config
test -e /usr/local/etc/ssh/sshd_config || cp /usr/local/etc/ssh/sshd_config.orig /usr/local/etc/ssh/sshd_config
if ! grep -q "^PasswordAuthentication" /usr/local/etc/ssh/sshd_config; then
	echo "PasswordAuthentication no" >>/usr/local/etc/ssh/sshd_config
fi
if ! grep -q "^AcceptEnv" /usr/local/etc/ssh/sshd_config; then
	echo "AcceptEnv COLORTERM LANG LC_*" >>/usr/local/etc/ssh/sshd_config
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
ln -s /usr/local/etc/fuse.conf /etc/fuse.conf

/opt/tinycloudinit.sh

cp /mnt/lima-cidata/meta-data /run/lima-ssh-ready

# Install the openrc lima-guestagent service script
cat >/usr/local/etc/init.d/lima-guestagent <<'EOF'
#!/bin/sh

start() {
	if [ ! -e /var/run/lima-guestagent.pid ]; then
		start-stop-daemon --start --exec /usr/local/bin/lima-guestagent --background -- daemon 2>/dev/null
	fi
}

stop() {
	start-stop-daemon --stop --exec /usr/local/bin/lima-guestagent 2>/dev/null
}

case $1 in
	start) start
		;;
	stop) stop
		;;
	*) echo -e "\n$0 [start|stop]\n"
		;;
esac
EOF
chmod 755 /usr/local/etc/init.d/lima-guestagent
/usr/local/etc/init.d/lima-guestagent start

cp /mnt/lima-cidata/meta-data /run/lima-boot-done
