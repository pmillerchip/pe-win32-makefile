# pe-win32-makefile
Makefile for using Linux to cross-compile all Win32 DLLs that ParentEve uses.

The Windows version of [ParentEve](http://www.parenteve.com/) is built under Linux
by cross-compiling it using the MinGW compiler. This Makefile downloads, unpacks,
builds and installs all the required dependencies with a single *make* command.

Just type *make* and eventually everything will be built. It creates a directory
called `rootfs` which will have the header files to build against, and the DLLs
to ship.

It will download official tarfiles and zipfiles from the Internet if needed.
If you put the correct files in place first, the download step is skipped.

The compiler used is *i686-w64-mingw32* which should be present on the system.
This Makefile has been tested on Ubuntu 14.04 amd64.
