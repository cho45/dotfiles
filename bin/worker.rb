#!/usr/bin/env ruby
=begin

eg.

# run worker proccess
$ worker.rb =fetch-video.pl /tmp/video

# queue proccess
$ echo http://www.nicovideo.jp/watch/nm5253338 >> /tmp/video

=end

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
