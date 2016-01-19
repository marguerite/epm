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
$path = "/tmp/#{dbname}"

def writedb(db={},dbname="",element="")
	if db.key?(dbname)
		db[dbname] << element
	else
		db.store(dbname,[element])
	end
end

def installfile(file="",mode=Integer.new)
	io = IO.popen("install -Dm" + mode.to_s + " " + $path + file + " " + file)
	io.each_line {|l| puts l }
	io.close
end

if arguments[0] == "install"
	# unpack
	Open3.popen3("tar -xvf #{file} -C /tmp") do |s1,s2,s3,w1|
		unless w1.value == 0
			sleep 1
		end
	end

	# generate filelist following system hirachy
	filelist = Array.new
	Dir.glob("#{$path}/**/*").each do |f|
		filelist << f.gsub($path,"")
	end
		
	filelist.each do |f|
		# dont do anything on existing directory
		unless File.directory?(f)
			if f.index("/bin")
				writedb(db,dbname,f)
				installfile(f,755)
			else
				writedb(db,dbname,f)
				installfile(f,644)
			end
		end
	end

	json = db.to_json
	File.open(dbfile,"w") {|f| f.puts json}

elsif arguments[0] == "remove"

end
