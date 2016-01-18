#!/usr/bin/env ruby

require 'fileutils'
require 'open3'
require 'json'

file,arguments,db = String.new,Array.new,Hash.new
dbfile = "database.json"
ARGV.each do |a|
	if a.index(".epm")
		file = a
	else
		arguments << a
	end
end

dbname = file.gsub(".epm","")
path = "/tmp/#{dbname}"

if arguments[0] == "install"
	# unpack
	Open3.popen3("tar -xvf #{file} -C /tmp") do |s1,s2,s3,w1|
		unless w1.value == 0
			sleep 1
		end
	end

	# generate filelist following system hirachy
	filelist = Array.new
	Dir.glob("#{path}/**/*").each do |f|
		filelist << f.gsub(path,"")
	end
		
	filelist.each do |f|
		# dont do anything on existing directory
		unless File.directory?(f)
			if f.index("/bin")
				db.store(dbname,[f])
				Open3.popen3("install -Dm755 #{path + f} #{f}") do |s1,s2,s3|
					s2.each_line {|l| puts l}
				end
			else
				# FIXME: dignose this if block
				if db.key?(dbname)
					db[dbname] << f
				else
					db.store(dbname,[f])
				end
				Open3.popen3("install -Dm644 #{path + f} #{f}") do |s1,s2,s3|
					s2.each_line {|l| puts l}
				end
			end
		end
	end

	json = db.to_json
	File.open(dbfile,"w") {|f| f.puts json}

end
