# tinycloud - tinycore and cloud-init

Adaptation of [Tiny Core Linux](http://tinycorelinux.net/), to add `#cloud-config` support for [Lima](https://lima-vm.io/).

The cloud-init script is from: <https://github.com/afbjorklund/tinycloudinit>

![white cloud](assets/cloud.png)

Versions:

`20M	CorePure64-15.0.iso` (CLI)

`33M	TinyCorePure64-15.0.iso` (GUI)

Packages:

`acpid.tcz bash.tcz coreutils.tcz util-linux.tcz openssh.tcz sshfs.tcz`

Note: the `acpid` daemon allows powering down the system, using ACPI.

Dep Tree:

```
acpid.tcz

bash.tcz
   readline.tcz
      ncursesw.tcz

coreutils.tcz
   gmp.tcz

util-linux.tcz
   readline.tcz
      ncursesw.tcz
   udev-lib.tcz

openssh.tcz
   openssl.tcz

sshfs.tcz
   fuse3.tcz
   glib2.tcz
      libffi.tcz
      pcre21042.tcz
   openssh.tcz
      openssl.tcz
```

## Packages

To install .tcz packages, use the regular 'tc' user:

```console
anders@lima-core:~$ sudo -i tc
^
   ( '>')
  /) TC (\   Core is distributed with ABSOLUTELY NO WARRANTY.
 (/-_--_-\)           www.tinycorelinux.net

tc@lima-core:~$
```

Then you will have access to the regular tce commands.

---

White Cloud image credit: Designed by macrovector / [Freepik](http://www.freepik.com)
