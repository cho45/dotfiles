#!/usr/bin/env ruby

require 'fileutils'

@command  = ARGV.shift
@file     = ARGV.shift
FileUtils.touch @file

loop do
	if File.size(@file) > 1
		exec = File.open(@file, "r+") { |f|
			f.flock File::LOCK_EX
			task = f.gets
			rest = f.read
			f.seek 0
			f.print rest
			f.truncate f.tell
			exec = "#{@command} #{task}"
		}
		puts exec
		system(exec)
	end

	sleep 1
end
