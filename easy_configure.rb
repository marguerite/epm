#!/usr/bin/env ruby

require 'open3'

builddir = Dir.pwd
tool = String.new

IO.popen("mkdir -p easy_build")

if Dir.glob(builddir + "/{configure,configure.ac,configure.in}")
	puts "found autotool-style file, build as autotool project"
	tool = "./configure"
	IO.popen("autoreconf -fiv") unless Dir.glob(builddir + "/configure")
	prefix = "--prefix=#{builddir}/easy_build"
elsif Dir.glob(builddir + "/CMakeLists.txt")
	puts "found cmake-style file, build as cmake project"
	tool = "cmake"
	prefix = "-DCMAKE_INSTALL_PREFIX=#{builddir}/easy_build"
elsif Dir.glob(builddir + "/*.pro")
	puts "found qmake-style file, build as qmake project"
	tool = "qmake"
	# FIXME
end

arguments = tool + " " + prefix
# FIXME not that easy actually
ARGV.each {|arg| arguments = arguments + " " + arg}

# get cpu cores
cores = String.new
Open3.popen3("nproc") do |stdin,stdout,stderr|
	cores = stdout.read
end

Open3.popen3(arguments) do |stdin,stdout,stderr,wait_thr|
	stdout.each_line { |l| puts l }
	exit_status = wait_thr.value
	if exit_status == 0
		Open3.popen3("make -j#{cores}") do |s1,s2,s3,w1|
			s2.each_line { |l| puts l }
			if w1.value == 0
				exit
			else
				abort "Build failed!"
			end
		end
	end
end
