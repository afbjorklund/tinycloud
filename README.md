# tinycloud - tinycore and cloud-init

Adaptation of [Tiny Core Linux](http://tinycorelinux.net/), to add `#cloud-config` support for [Lima](https://lima-vm.io/).

The cloud-init script is from: <https://github.com/afbjorklund/tinycloudinit>

![white cloud](assets/cloud.png)

Versions:

`20M	CorePure64-15.0.iso` (CLI)

`32M	TinyCorePure64-15.0.iso` (GUI)

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

util-linux.tcz
   readline.tcz
      ncursesw.tcz
   udev-lib.tcz

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

---

White Cloud image credit: Designed by macrovector / [Freepik](http://www.freepik.com)
