# Studio

Studio is an interactive software diagnostics environment.

Studio imports dense and "messy" diagnostic data in an application's
own native formats, then it applies all the tools that are needed to
extract useful information, and finally it presents the results in an
interactive graphical user interface.

### Getting Started

Studio runs on Linux/x86-64 and publishes its GUI via VNC. You can run
Studio on a Linux server, or in a Docker container on
Linux/macOS/Windows, or in a virtual machine and then access the GUI
using a VNC client. (You can also run Studio directly via X11 if you
prefer.)

#### Connecting with VNC

Once you have Studio running in VNC mode you can connect to the GUI like this:

```shell
vncviewer hostname:1
```

where *hostname* is the machine running Studio and *:1* is the VNC
desktop number (corresponding to TCP port 5901.)

We recommend using a VNC client such
as [TigerVNC](https://tigervnc.org/) that supports automatically
resizing the desktop to match your client window.

#### Running Studio in Docker

You can run Studio via the Dockerhub
repository
[`studioproject/master`](https://hub.docker.com/r/studioproject/master).
Studio CI automatically publishes the latest working build of the
`master` branch (and every other branch) to Dockerhub for easy
installation.

Here is a one-liner to start Studio in a Docker container (on
macOS/Windows this automatically runs inside a Linux VM):

```shell
docker run --rm -ti -p 127.0.0.1:5901:5901 studioproject/master vnc
```

You can then connect to the GUI on VNC display `127.0.0.1` because TCP
port 5901 is forwarded into the container.

Docker tips:

- `docker pull studioproject/master` will upgrade to the latest Studio image from CI.
- `docker run ... studioproject/FOO` will run Studio from the branch named FOO (for any value of FOO.)
- `docker build .` will build the Docker container for Studio from source.
- `docker run -v /:/host` bind-mounts local files to be accessible to Studio under `/host/*` from inside the container.

#### Running Studio directly on Linux

You can also run Studio on Linux directly from source:

```shell
# Install the Nix package manager to automatically manage dependencies.
curl https://nixos.org/nix/install | sh

# Setup Cachix to speed up Nix by downloading cached binaries when available.
# (This step is optional but recommended.)
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use studio 

# Download and run Studio
git clone https://github.com/studio/studio
studio/bin/studio vnc  # or x11
```

----

<p align="center"> <img src="studio.svg" alt="Studio screenshot" width=600> <br/> RaptorJIT IR visualization example </p>

