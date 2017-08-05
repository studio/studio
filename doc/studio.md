# Introduction

Studio is a productive environment for working on your programs.

Studio provides a unified graphical interface for a plethora of
special-purpose software development tools. You can have hundreds of
tools - debuggers, profilers, linters, disassemblers, decompilers,
benchmarks, etc - and Studio keeps them all within arm's reach. Studio
also provides a framework where you can integrate your own custom
domain-specific tools to help you with specific applications.

Studio is internally composed of a backend and a frontend. The backend
can use practically any programming languages and software libraries
to produce data for inspection. The frontend then presents this data
using Pharo, a Smalltalk dialect, using a paradigm called "moldable
tools" and its associated software frameworks. The user interactively
makes requests to the backend - writing scripts or clicking widgets -
and browses the results in the frontend.

# Using Studio

Studio is a GUI application for Linux/x86-64. You can run Studio directly (X11 mode) or remotely (VNC mode.) Both modes are supported "out of the box."

macOS users can use VNC mode to run Studio on a server, a cloud VM, a Docker container, a VirtualBox VM, etc.

The ideal deployment environment is a server with plenty of resources. The Studio backend does extensive parallelization and caching so it is able to make good use of CPU cores, network bandwidth, RAM, disk space, etc.

You can also run Studio on many different machines, at the same time
or at different times, because these installations do not store any
important state on local storage. Everything is accessed from the
network and local storage is only used for caching.

## Installation

### Prerequisites

Studio is installed using the Nix package manager. You need to install Nix before installing Studio.

Here is a one-liner for installing Nix:

```
$ curl https://nixos.org/nix/install | sh
```

### Install

You can install Studio directly from a source tarball. Here is the
command to install the current master branch:

```
$ nix-env -iA studio -f https://github.com/studio/studio/archive/master.tar.gz
```

### Upgrade and downgrade

Studio can be updated to the latest version by re-running the
installation command. The URL can be updated to point to any Studio
source archive. Switching back and forth between multiple versions is
no problem.

## Starting Studio

You can run the Studio GUI either locally (X11) or remotely (VNC.) The
command `studio-x11` runs the GUI directly on your X server while the
command `studio-vnc` creates a VNC desktop running Studio for remote
access.

Usage:

```
$ studio-x11
$ studio-vnc [extra-vncserver-args...]
```

The VNC server used is `tigervnc`.


### VNC and SSH remote access tips

The recommended VNC client is `tigervnc` which supports
automatically resizing the desktop to suit the client window
size. On macOS with Homebrew you can install tigervnc with `brew
  cask install tigervnc-viewer` and then run `vncviewer
<server>[:display]`.

Here is a Studio-over-SSH cheat sheet:

- Start a long-lived Studio session: `ssh <server> studio-vnc
  [:display]`. If no display is specified then an available one is
  assigned automatically.
- Setup SSH port forwarding to (e.g.) display 7: `ssh -L
  5907:localhost:5907 <server>`.
- Connect with VNC client to (e.g.) display 7 over SSH forwarded
  port: `vncviewer localhost:7`.
- Shut down a Studio sessions: `ssh <server> vncserver -kill
  <:display>`.

## Using Studio
### Writing a Nix expression
### Selecting objects to inspect
### Selecting views for objects
### Navigating back and forth
### Split/Unsplit the inspector
### Further reading
# Extending Studio
## Products
## Extending the backend
## Extending the frontend
## Examples
### Example: Inspecting plain files
### Example: Inspecting pcap files with wireshark
### Example: Inspecting the contents of archives
# API reference
## RaptorJIT
## Snabb
