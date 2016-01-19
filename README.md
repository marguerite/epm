# Easiest Package Manager

This is probably the easiest package manager existing.

It just automatically packages what you compile on your local system, by tweaking install location automatically and monitoring file changes in the build directory.

## Usage

Inside the source code directory:

	epmbuild configure
	epmbuild install
	epmbuild pack

You can pass through everything like "--libdir=/usr/lib64" to `epmbuild configure`.

Use the `epm` command to install it:

	epm install *.epm

# Status

Now it can handle autotools and cmake projects.

# TODO 

* dependencies handling (compatible with rpm/deb in file level)
* command line regex expand (epm install \*.epm)
	
