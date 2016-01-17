# Easiest Package Manager

This is probably the easiest package manager existing.

It just automatically packages what you install on your local system, by monitering file changes in /usr /etc and the build directory. but I suggest you specify the prefix to some place inside the build directory, eg:

	easy_configure 
	make
	easy
	easy_pack

The generated `.epm` is actually `.tar.xz` format. I suggest you use the `epm` command to install it, which will handle the dependencies for you.

# Status

Now it can handle autotools, cmake and qmake.

# TODO 

* dependencies handling (compatible with rpm/deb in file level)
* epm itself
	
