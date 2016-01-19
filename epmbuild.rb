#!/usr/bin/env ruby

require 'rbconfig'
require 'fileutils'

builddir = Dir.pwd
workspace = builddir + "/epmbuild"

# get cpu cores
io = IO.popen("nproc")
cores = io.read.strip!
io.close

if ARGV[0] == "configure"

	IO.popen("mkdir -p epmbuild")

	if Dir.glob(builddir + "/{configure,configure.ac,configure.in}")
		puts "found autotool-style file, build as autotool project"
		tool = "./configure"
		IO.popen("autoreconf -fiv") unless Dir.glob(builddir + "/configure")
		prefix = "--prefix=" + workspace
	elsif Dir.glob(builddir + "/CMakeLists.txt")
		puts "found cmake-style file, build as cmake project"
		tool = "cmake"
		prefix = "-DCMAKE_INSTALL_PREFIX=" + workspace
	elsif Dir.glob(builddir + "/*.pro")
		puts "found qmake-style file, build as qmake project"
		tool = "qmake"
		# FIXME
	end

	arguments = tool + " " + prefix
	ARGV.drop(1).each do |arg|
		# --mandir=/usr/share/man
		# automatically prepend epm build
		if arg.index("=/")
			pre = arg.gsub(/\/.*$/,'')
			post = arg.gsub(/^.*=/,'')
			arg = pre + workspace + post
			p arg
		end
		arguments = arguments + " " + arg
	end

	io = IO.popen(arguments)
	io.each_line {|l| puts l}
	io.close
	unless $? == 0
		abort "configure failed!"
	end

	io1 = IO.popen("make -j" + cores)
	io1.each_line {|l| puts l}
	io1.close
	unless $? == 0
		abort "build failed!"
	end	

elsif ARGV[0] == "install"

	oldlist, newlist = [],[]
	Dir.glob("**/*") {|f| oldlist << f}

	# accept optional arguments
	arguments = ""
	ARGV.drop(1).each {|i| arguments = arguments + " " + i}
	
	io = IO.popen("make install -j" + cores + " " + arguments)
	io.each_line {|l| puts l}
	io.close

	Dir.glob("**/*") {|f| newlist << f}

	diff = newlist - oldlist

	puts "Files waiting to be packaged:\n#{diff}\nPlease run \"easy_pack\" command."

elsif ARGV[0] == "pack"

	destdir = builddir.gsub(/^.*\//,'')
	arch = RbConfig::CONFIG["arch"].gsub("-linux",'')
	pkg = destdir + arch

	FileUtils.mv("epmbuild",pkg)

	io = IO.popen("tar -cvf #{pkg}.tar #{pkg}")
	io.each_line {|l| puts l.gsub(pkg,'')}
	io.close
	
	if $? == 0
		io1 = IO.popen("xz -z -9 #{pkg}.tar")
		io1.close
		if $? == 0
			FileUtils.mv("#{pkg}.tar.xz","#{pkg}.epm")
		end
	end

else

	puts "invalid option: #{ARGV[0]}. use: configure, install, pack."

end
