Studio is an extensible debugger intended for great applications that deserve their own tooling. It's built on Nix and Pharo. Development for [Snabb](http://snabb.co/) use cases started in January 2017!

## Workflow

The Studio workflow is in three parts: collect data from your application, process it in infinitely many weird and wonderful ways, and present it using a unified graphical UI.

Collect primary data from your application:
- Executable files containing debug information.
- Raw process snapshots such as coredumps.
- Logs of all shapes and sizes (text, binary, etc.)
- Profiler data (perf recordings, PEBS buffers, coverage reports, etc.)
- Step-by-step evaluation recordings for replay.
- Other specialized information that you make available.

Create and store intermediate artifacts using [Nix](http://www.nixos.org/):
- Convert from specialized formats (e.g. coredump/DWARF/PCAP) to generic ones (e.g. CSV/JSON/XML.)
- Summarize information with statistics, comparisons, validity tests, etc.
- Use every tool you want: awk, Python, R, GDB, Wireshark, QEMU, etc.
- Support multiple versions of each tool including custom patches.
- Transfer data between machines while preserving immutable identifies.

Present information using the [Pharo Glamorous Toolkit](http://gtoolkit.org/):
- Inspect the low-level (C heap), mid-level (programming langauge runtime), and high-level (application) objects.
- Click through related objects like source code, byte code, JIT machine code, and profiler reports.
- Search all intermediate information using the Spotter.
- Write code interactively to access the store.

## Background

Studio is initially being developed for Snabb hackers. Snapshots with
offline analysis makes sense because we need to examine production
systems that cannot pause for more than a millisecond and are not
accessible to developers. Nix makes sense to store primary data immutably, 
cache all intermediate representations, backup and transfer easily, farm out
expensive data production & processing to a distributed cluster, and access
diverse messy dependencies in a disciplined way. Pharo makes sense because
the Glamorous Toolkit's "moldable" style is designed for creating
user-friendly application-aware software development environments.

Studio will allow us to "go nuts" on experimenting with fancy
development tools while keeping our production software
minimalist. The software we deploy only has to produce data somewhere -
even simply inside its own process heap in an internal format - and
Studio can do unlimited decoding, analysis, and visualization.
This separation of concerns should be liberating.

## Related work

- [Intel VTune](https://software.intel.com/en-us/intel-vtune-amplifier-xe) is a proprietary micro-optimization tool. Studio aims to cover these use cases as open source.
- [gdb](https://www.sourceware.org/gdb/) is a powerful debugger that can operate on both running programs and offline core dumps. Studio aims to be more application-aware and easier to use for casual programmers.
- [rr](https://github.com/mozilla/rr) is a back-in-time replay extension for gdb. (Genius idea!) Studio aims to support applications like Snabb that perform many gigabytes per second of I/O and DMA.
- [ddd](https://www.gnu.org/software/ddd/) is a graphical front-end to GDB and related debuggers. Studio is another take on this approach with emphasis on application-specific extension.
- Lisp environments like SLIME and LispWorks provide an interactive software development workflow. Studio aims to provide similar visibility of the process heap but with emphasis on offline execution. (Tangential idea: a REPL that records a coredump after each command and lets Studio discover and present the differences.)
- Popular IDEs like Emacs, Atom, Eclipse, IntelliJ, Visual Studio are mostly for writing and maintaining source code. Studio is a mostly complementary tool for analysing runtime behavior.

## History

Studio was started in 2017 by Luke Gorrie as a unified framework for collecting Snabb development tools. Luke previously started the [SLIME](https://github.com/slime/slime) project for Common Lisp and the [Distel](https://github.com/massemanet/distel) project for Erlang.

