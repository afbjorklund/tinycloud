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

# When running from RAM try to move persistent data to data-volume
if [ "$(awk '$2 == "/" {print $3}' /proc/mounts)" == "rootfs" ]; then
	mkdir -p /mnt/data
	if [ -e /dev/disk/by-label/data-volume ]; then
		# Find which disk is data volume on
		DATA_DISK=$(blkid | grep "data-volume" | awk '{split($0,s,":"); sub(/\d$/, "", s[1]); print s[1]};')
		# Automatically expand the data volume filesystem
		partextend "$DATA_DISK" 1 || true
		partx -u "$DATA_DISK"
		# Only resize when filesystem is in a healthy state
		if e2fsck -f -p /dev/disk/by-label/data-volume; then
			resize2fs /dev/disk/by-label/data-volume || true
		fi
		# Mount data volume
		mount -t ext4 /dev/disk/by-label/data-volume /mnt/data
	else
		# Find an unpartitioned disk and create data-volume
		DISKS=$(lsblk --list --noheadings --output name,type | awk '$2 == "disk" {print $1}' | grep -v zram)
		for DISK in ${DISKS}; do
			IN_USE=false
			# Looking for a disk that is not mounted or partitioned
			# shellcheck disable=SC2013
			for PART in $(awk '/^\/dev\// {gsub("/dev/", ""); print $1}' /proc/mounts); do
				if [ "${DISK}" == "${PART}" ] || [ -e /sys/block/"${DISK}"/"${PART}" ]; then
					IN_USE=true
					break
				fi
			done
			if [ "${IN_USE}" == "false" ]; then
				echo 'type=83' | sfdisk --label dos /dev/"${DISK}"
				partx -a /dev/"${DISK}"
				PART=$(lsblk --list /dev/"${DISK}" --noheadings --output name,type | awk '$2 == "part" {print $1}')
				until [ -e /dev/"${PART}" ]; do sleep 1; done
				mkfs.ext4 -L data-volume /dev/"${PART}"
				mount -t ext4 /dev/"${PART}" /mnt/data
				break
			fi
		done
	fi
	# Use data-volume for packages
	TCEDIR=/mnt/data/tce
	if [ ! -d "$TCEDIR"/optional ]; then
		mkdir -p "$TCEDIR"/optional
		chown -R tc:staff "$TCEDIR"
		chmod -R g+w "$TCEDIR"
	fi
	rm -f /etc/sysconfig/tcedir
	ln -s ${TCEDIR} /etc/sysconfig/tcedir
fi

while read -r line; do export "$line"; done </mnt/lima-cidata/lima.env

if [ "${LIMA_CIDATA_MOUNTTYPE}" = "reverse-sshfs" ]; then
	# Create mount points
	# NOTE: Busybox sh does not support `for ((i=0;i<$N;i++))` form
	for f in $(seq 0 $((LIMA_CIDATA_MOUNTS - 1))); do
		mountpointvar="LIMA_CIDATA_MOUNTS_${f}_MOUNTPOINT"
		mountpoint="$(eval echo \$"$mountpointvar")"
		mkdir -p "${mountpoint}"
		gid=$(id -g "${LIMA_CIDATA_USER}")
		chown "${LIMA_CIDATA_UID}:${gid}" "${mountpoint}"
	done
fi

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
