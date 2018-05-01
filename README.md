# Studio

Studio is a debugger for the data produced by complex applications.
Studio imports dense and "messy" data in an application's own native
formats, then it applies all the tools that are needed to extract
useful information, and finally it presents the results in an
interactive graphical user interface.

### Getting Started

How to download and run:

```shell
$ curl https://nixos.org/nix/install | sh    # Get nix
$ git clone https://github.com/studio/studio # Get studio
$ studio/run vnc                             # to start GUI as VNC server
```

Optional extras:

```
$ git checkout next      # to try development version
$ studio/run x11         # to start GUI as X11 client
```

Script you can enter to get some example data:

```
with import <studio>;
raptorjit.runTarball https://github.com/lukego/rj-vmprof-bench/archive/master.tar.gz
```

----

<p align="center"> <img src="studio.svg" alt="Studio screenshot" width=600> <br/> RaptorJIT IR visualization example </p>

