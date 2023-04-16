# tinycloud - tinycore and cloud-init

Adaptation of [Tiny Core Linux](http://tinycorelinux.net/), to add `#cloud-config` support for [Lima](https://lima-vm.io/).

The cloud-init script is from: <https://github.com/afbjorklund/tinycloudinit>

Versions:

`18M	CorePure64-13.1.iso` (CLI)

`30M	TinyCorePure64-13.1.iso` (GUI)

Packages:

`acpid.tcz bash.tcz coreutils.tcz openssh.tcz sshfs.tcz`

Note: the `acpid` daemon allows powering down the system, using ACPI.

Dep Tree:

```
acpid.tcz

bash.tcz
   readline.tcz
      ncursesw.tcz

coreutils.tcz
   acl.tcz
   gmp.tcz
   libcap.tcz

openssh.tcz
   openssl-1.1.1.tcz

sshfs.tcz
   fuse3.tcz
   glib2.tcz
      libffi.tcz
      pcre.tcz
   openssh.tcz
      openssl-1.1.1.tcz
```
