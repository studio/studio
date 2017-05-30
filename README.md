# Studio

Studio is an extensible software diagnostics suite. It provides a
framework for creating and sharing application-specific tools for
debugging, benchmarking, profiling, and so on.

Studio is a new project. We are using it to create specialized tools
for [Snabb](https://github.com/snabbco/snabb). You are welcome to get
involved if you also have a project that needs custom tooling.

## Installation

```shell
# Install the Nix package manager
$ curl https://nixos.org/nix/install | sh

# Checkout Studio from the Git repository
$ git clone https://github.com/studio/studio

# Run Studio directly from the source tree
$ studio/bin/studio --help
```

Studio will automatically download and build its software dependencies
as they are needed using [Nix](http://nixos.org/nix/). This means that
you will see a lot of activity the first time you run a given command,
so please be patient. The downloads will be cached for future use, and
Nix will isolate all of the software in the `/nix/store/` directory to
prevent conflicts with your other applications.

## Design

Studio is built on three layers of software:

The **frontend** presents a unifying graphical user interface. The
frontend is based on [Pharo](http://pharo.org/) using the "moldable
tools" approach with [The Glamorous Toolkit](http://gtoolkit.org/).
(There is also a basic unix shell frontend.)

The **backend** converts raw diagnostic data (logs, core dumps,
profiler dumps, etc) into understandable information (graphs, tables,
reports). The backend uses [Nix](http://nixos.org/nix/) for structured
step-by-step processing.

The **tools** implement individual processing steps for the backend.
Tools can be written in any programming language. Some tools are
written specifically for Studio, for example to produce information in
a special format for the frontend. Other tools are taken off the shelf
e.g. objdump to disassemble machine code, wireshark to decode network
traffic, `perf` to analyze performance reports, and so on.

## Status

Studio is new and raw. Here is what the initial commands look like:

```shell
$ studio --help
Studio: the extensible software diagnostics suite

Usage:

  studio [common-options] <command> ...

Commands:

    studio gui                 Studio GUI front-end (NYI).
    studio snabb               Snabb diagnostic tools.
    studio rstudio             RStudio IDE with relevant packages.

For detailed command help:
    studio <command> --help

Common options:

    -v, --verbose              Print verbose nix trace information.
    -j, --jobs NUM             Execute NUM build jobs in parallel.
                               Defaults to 8 or .
    -n, --nix ARGS             Extra arguments for nix-build.
                               Defaults to .

$ studio snabb --help
Subcommands for 'studio snabb':

    studio snabb processes     Analyze a set of Snabb processes.
    studio snabb vmprofile     Analyze "VMProfile" data from one process.

For detailed subcommand help:
    studio snabb <subcommand> --help
$ studio snabb processes --help
Usage:

    studio snabb processes [option|directory]*

Arguments:

    DIRECTORY                  Snabb process state directory to analyze.
                               Many directories can be specified.
    -g, --group GROUP          Group name for the following Snabb processes.
                               Use to assign Snabb processes to groups.

    -o, --output PATH          Create output (symlink to directory) at PATH.

$ studio snabb vmprofile --help
Usage:

    studio snabb vmprofile [option]* <directory>

Arguments:

    DIRECTORY                  Snabb process state directory to analyze.
                               Exactly one directory must be provided.
    -o, --output PATH          Create output (symlink to directory) at PATH.

$ studio rstudio --help
Usage:

    studio rstudio

Runs the RStudio IDE (https://www.rstudio.com/) with the packages
relevant to Studio available in the appropriate version. 

This provides an environment for writing R code that works as expected
when deployed with Studio.
```
