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
with Pharo, a Smalltalk dialect, using a paradigm called "moldable
tools."

The user interactively inspects a series of objects. The backend
builds each object and then the frontend presents it. Presentations
are interactive and often the user will use the first object to
navigate to many more. The first object is specified by writing a
script (a Nix expression.)

## How Studio Works

Studio is built on three main abstractions: _products_, _builders_, and _presentations_. Products are raw data on disk; builders are scripts that can create products; presentations are graphical views of products.

### Products

A product is raw data - a directory on disk - in a well-defined
format. Each product has a named _type_ that informally defines the
layout of the directory and the characteristics of the files. The type
is always specified in a file named `.studio/product-info.yaml`.

For a running example, let us define a product type called
`xml/packet-capture/pdml` that represents a network packet capture in
XML format. Here is how we informally define this product type:

- The file `.studio/product-info.yaml` will include `type: xml/packet-capture/pdml`.
- The file `packets.pdml` will exist at the top-level.
- `packets.pdml` will contain network packets in the [PDML](https://wiki.wireshark.org/PDML) XML format defined by Wireshark.

This simple product definition defines the interface between builders,
that have to produce directories in this format, and presentatins that
will display those directories to the user.

Digression: One can imagine many other product types. For example, a
type `application/crash-report` might represent debug information
about an application that has crashed and include the files `exe` (an
ELF executable with debug symbols), `core` (a core dump at the point
of the crash), `config.gz` (Linux kernel configuration copied from
`/proc/config.gz`), and so on. Such products could serve as
intermediate representations from which to derive other products, like
high-level summaries or low-level disassembly of the relevant
instructions, using tools like `gdb` and `objdump` and so on.

### Builders

A builder is a script - a Nix derivation - that creates one or more
products. The builder takes some inputs - parameters, files, URLs,
output of other builders, etc - and uses them to produce a
product. Certain builders have simple high-level APIs that are easy
for users to call interactively. Other builders have intricate APIs
and are used as component parts of higher-level builders.

A builder also takes all of the software that it requires as an
input. This is completely natural with Nix. If specific software is
needed, in specific versions, from specific Git branches, with
specific patches, etc, then it can be provided with Nix. Indeed, most
common software packages are already available out of the box from the
`nixpkgs` package repository and can easily have their versions
overridden.

For example, let us define a builder that takes for input the URL of a packet capture in binary `pcap` file format and for output creates a product of type `xml/packet-capture/pdml`.

```nix
# pdml api module
pdml = {
  # inspect-url function
  inspect-url = pcap-url:
    runCommand "pdml-from-pcap-url"
      # inputs
      {
	pcap-file = fetchurl pcap-url;
	buildInputs = [ wireshark ];
      }
      # build script
      ''
	mkdir -p $out/.studio
	echo 'type: xml/packet-capture/pdml' > $out/.studio/product-info.yaml
	tshark -t pdml -i ${pcap-file} -o $out/packets.pdml
      '';
}
```

This builder can be invoked in a script like this:

```nix
pdml.inspect-url http://my.site/foo.pcap
```

and it will produce a Studio product as a directory in exactly the
expected file format.

Note: We have specified our software dependency simply with the name
`wireshark`. This means that Studio will download and use the default
version in the base version of nixpkgs. That is, Studio would always
use exactly the same version of wireshark no matter where it is
running. If we wanted to use a more specific version, or apply patches to
support some new experimental protocols, etc, then this would be
straightforward with Nix.

### Presentations

A presentation is an interactive user interface - a live Smalltalk object - that presents a product (or a component part of a product) to the user. The input to the presentation is a product stored on the local file system. The presentation code then adds new _view_ tabs to the inspector.

```smalltalk
StudioPresentation subclass: #PDLPacketCapturePresentation
  instanceVariableNames: 'xml'
  classVariableNames: ''
  package: 'Studio-UI'
```

```
PDLPacketCapturePresentation class >> supportsProductType: type
   ^ type = 'xml/packet-capture/pdl'.
```

```smalltalk
PDLPacketCapturePresentation >> openOn: dir
   xml := XMLDomParser parseFileNamed: dir / 'packets.pdml'.
```

```smalltalk
PDLPacketCapturePresentation >> gtInspectorPacketsIn: composite
   <gtInspectorPresentationOrder: 1>
   "Reuse the standard XML tree view."
   xml gtInspectorTreeIn: composite.
```

### Extensions

Once we have defined a product type, a builder, and a presentation then we have added a new capability to Studio.

We can run our builder on the URL of a standard Wireshark example trace for a PPP handshake:

```
pdml.inspect-url https://wiki.wireshark.org/SampleCaptures?action=AttachFile&do=get&target=PPPHandshake.cap
```

which creates the product for our presenter to show as an XML tree:

![XML PDL Tree browser](images/PDML.png)

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

## Operating the Studio UI
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
