# Studio

Studio is an extensible software diagnostics framework. It is for
creating and sharing debugging, benchmarking, and profiling tools for
applications.

Studio aims to make simple things easy and hard things possible.
Simple could be to make an A/B comparison benchmark to detect and
understand a performance regression introduced in a new software
version. Hard could be to account for differences in performance
between a test lab and a production environment.

Studio is a vehicle for applying your own tools and expertise in a
systematic, automated, and reproducible way.

## Design

Studio is built on three layers of software:

The **frontend** presents a unifying graphical user interface. The
frontend is written in [Pharo](http://pharo.org/) using the "moldable
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

Studio is currently (May 2017) in an early stage of development. The
initial backend and tools are there. There is a command-line interface
(`bin/studio`) but not yet the graphical frontend.

## Background

Studio was originally created to support [Snabb](http://snabb.co/)
development. Snabb is a performance-sensitive application that is
developed by many groups in a distributed fashion (similar to the
Linux kernel.) Studio is intended to speed up our benchmarking,
optimization, and troubleshooting activities by automating and sharing
our workflows.

