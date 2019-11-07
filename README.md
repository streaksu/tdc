# TDC, the Tiny D Compiler

TDC is a D compiler using the [DMD](https://dlang.org) frontend (v2.088.1) and
a custom backend.

## Building
To build the compiler only a previous D compiler (`ldc` or `dmd`) is needed.

The instructions for a UNIX-like system are the following:

```bash
meson --buildtype=release build # Prepare the build directory.
cd build && ninja               # Build the source.
ninja test                      # Test suites.
ninja install                   # Install, may require superuser permissions.
```
