#!/bin/sh
kernel_version=6.6.8

kernel_volumes="--volume $PWD/kernel_config:/home/tc/kernel_config \
                --volume $PWD/kernel_defconfig:/home/tc/kernel_defconfig \
                --volume $PWD/kernel_patches:/home/tc/kernel_patches"

docker container inspect --format '{{.Id}}' tinycore-kernel \
	|| docker run -d --name=tinycore-kernel $kernel_volumes tinycore-compiletc:15.0-x86_64 sleep 3600
$(docker inspect --format '{{.State.Running}}' tinycore-kernel) \
	|| docker start tinycore-kernel

test -r linux-$kernel_version.tar.xz \
	|| wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$kernel_version.tar.xz
docker exec tinycore-kernel test -e /home/tc/linux-$kernel_version.tar.xz \
	|| docker cp linux-$kernel_version.tar.xz tinycore-kernel:/home/tc/linux-$kernel_version.tar.xz

chmod 666 kernel_config
chmod 666 kernel_defconfig

docker exec -i tinycore-kernel sh -x < compile_kernel
docker exec -i tinycore-kernel sh -x < package_kernel

docker cp tinycore-kernel:/home/tc/vmlinuz64 vmlinuz64
docker cp tinycore-kernel:/home/tc/modules modules
