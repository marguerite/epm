#!/usr/bin/env ruby

require 'open3'

builddir = Dir.pwd
oldlist, newlist = Array.new, Array.new

Dir.glob("**/*") do |f|
	oldlist << f
end

# accept optional arguments
arguments = String.new
ARGV.each {|i| arguments = arguments + " " + i}

# detect cpu numbers
cpu = String.new
Open3.popen3("nproc") do |stdin,stdout,stderr|
	cpu = stdout.read
end

Open3.popen3("make install -j#{cpu} DESTDIR=#{builddir}/easy_build #{arguments}") do |stdin,stdout,stderr|
	stdout.each_line {|l| puts l}
end

Dir.glob("**/*") do |f|
	newlist << f
end

diff = newlist - oldlist

puts "Files waiting to be packaged:\n#{diff}\nPlease run \"easy_pack\" command."
