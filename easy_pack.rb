#!/usr/bin/env ruby

require 'rbconfig'
require 'fileutils'
require 'open3'

dir = Dir.pwd
destdir = dir.gsub(/^.*\//,'')
arch = RbConfig::CONFIG["arch"].gsub("-linux",'')
package = destdir + "." + arch

FileUtils.mv("easy_build",package)

Open3.popen3("tar -cvf #{package}.tar #{package}") do |stdin,stdout,stderr,wait_thr|
	exit_status = wait_thr.value
	stdout.each_line {|l| puts l}
	if exit_status == 0
		Open3.popen3("xz -z -9 #{package}.tar") do |s1,s2,s3,w1|
			e1 = w1.value
			if e1 == 0
				FileUtils.mv("#{package}.tar.xz","#{package}.epm")
			end
		end
	end
end
