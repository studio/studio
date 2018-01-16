# Studio

Studio is a debugger for the data produced by complex applications.
Studio imports dense and "messy" data in an application's own native
formats, then it applies all the tools that are needed to extract
useful information, and finally it presents the results in an
interactive graphical user interface.

### TLDR

Get up and running on Linux:

```shell
$ curl https://nixos.org/nix/install | sh    # Get nix
$ git clone https://github.com/studio/studio # Get studio
$ cd studio
$ git checkout next      # to try development version
$ studio/bin/studio vnc  # to start GUI as VNC server
$ studio/bin/studio x11  # to start GUI as X11 client
```

Script to load some interesting example data:

```
with import <studio>;
raptorjit.runTarball https://github.com/lukego/rj-vmprof-bench/archive/master.tar.gz
```

### RTFM

See the current manual for the [master](https://hydra.snabb.co/job/lukego/studio-manual/studio-manual-html/latest/download-by-type/file/Manual) release branch or
the [next](https://hydra.snabb.co/job/lukego/studio-manual-next/studio-manual-html/latest/download-by-type/file/Manual) development branch.

----

<p align="center"> <img src="studio.svg" alt="Studio screenshot" width=600> <br/> RaptorJIT IR visualization example </p>

