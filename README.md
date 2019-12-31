# TDC, the Tiny D Compiler

TDC is a D compiler using the [DMD](https://dlang.org) frontend and
a custom backend.

## Building
To build the compiler only a previous D compiler (`ldc` or `dmd`) is needed.

The instructions for a UNIX-like system are the following:

```bash
make -j4 # Build the source.
```

## The frontend
The DMD frontend version is v2.088.1.

The frontend source is organised in 2 directories:
- `source/dmd`: DMD's `src/dmd` source copied with a few modifications.
- `source/dmdres`: DMD's support files, for example, string included files.

The files on `source/dmd` vary with DMD's version in the following:
- The `backend` dir was removed directly.
- `dinifile.d` has `SYSCONFDIR.imp` searching commented out (line 103).
- Removed `dmsc.d`, `eh.d`, `e2ir.d`, `s2ir.d`, `glue.d`, `objc_glue.d`, `iasmdmd.d`,
    `irstate.d`, `tocsym.d`, `tocvdebug.d`, `todt.d`, `toir.d`, `toobj.d`, and `toctype.d`.
- All `*.h` files have been removed for obvious reasons.
