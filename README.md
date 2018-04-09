Runtime-less disassembly of Borland's `MAKER.EXE`, version 4.0, bundled with
Turbo Assembler 5.0, created to figure out why the hell autodependencies aren't
working as I would expect.

You will need the following to compile this back into the original binary:

* Borland C++ 5.01.

  Yes, and by that I mean probably this specific version. 4.52 is too old, 5.02
  is too new. 4.53 and 5.0 are untested.

* Borland Turbo Assembler (TASM), version 5.0 or later, in a 16-bit Protected
  Mode DOS version (`TASMX.EXE`). `TASM32.EXE` would work too, but `TASMX.EXE`
  can keep the build process entirely 16-bit.

* [DOSBox](http://dosbox.com) if you're running a 64-bit version of Windows, or
  a non-Windows operating system.

  To build, simply run `build16b.bat` and follow the instructions.