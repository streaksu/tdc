# TDC, the Tiny D Compiler

TDC is a D compiler using the [DMD](https://dlang.org) frontend (v2.088.1) and
a custom backend.

## Building
To build the compiler only a previous D compiler (`ldc` or `dmd`) is needed.

The instructions for a UNIX-like system are the following:

```
meson build && cd build # Prepare the build directory
ninja                   # Build the source, will make use of several cores.
ninja test              # Test suites.
ninja install           # Install if wanted, may require superuser permissions.
```
