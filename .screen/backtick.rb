#!/usr/bin/ruby

require "open3"
require "drb/drb"
require "thread"
NAME = "AsyncRunDRb/screen"

`/bin/ps -x -o pid=pid,command=comand`.split(/\n/).map {|i| i.strip.split(/\s+/) }.each {|pid, command|
	system "kill", pid if command.include?(NAME)
}
$0 = NAME

# system("screen", "-X", "eval", 'hardstatus alwayslastline "%-w %{.r.}%{!}%n%f%t%{dd} %+w"')

$stdout.sync = true

class AsyncRun
	def initialize
		@queue = Queue.new
		Thread.start do
			loop do
				run_queue
			end
		end
	end

	def add_queue(env, command)
		@queue << [env, command]
	end

	def run_queue
		$0 = "#{NAME} waiting..."
		env, command = @queue.pop
		$0 = "#{NAME} #{command}"
		prev_env = ENV.to_hash
		ENV.replace(env)
		ENV["LANG"] = "C"
		Dir.chdir(env["PWD"]) do
			Open3.popen3(command) do |stdin, stdout, stderr|
				stdin.close
				out = Thread.start do
					stdout.each do |l|
						puts l.gsub(/[^-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\]\s]/n, "#")
					end
				end
				err = Thread.start do
					stderr.each do |l|
						puts l.gsub(/[^-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\]\s]/n, "#")
					end
				end
				out.join
				err.join
			end
		end
	ensure
		ENV.replace(prev_env)
	end
end

DRb.start_service("druby://localhost:9999", AsyncRun.new)
puts DRb.uri

case RUBY_PLATFORM
when /linux/
	def network
		s = File.readlines("/proc/net/dev").detect {|i| i[/^\s*eth0/]}.split(/:|\s+/)
		[s[2].to_i, s[10].to_i]
	end

	def cpu_stat
		_, *s = *File.read("/proc/stat").match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
		s.collect {|i| i.to_i}
	end

	stats = []
	prev_net = network
	prev_cpu = cpu_stat


	loop do
		sleep 1

		# network
		now = network
		stats << [now[0] - prev_net[0], now[1] - prev_net[1]]
		stats = stats.last(10)

		down, up = stats.inject {|r,i| [r[0]+i[0], r[1]+i[1]] }.map {|i|
			i.to_f / stats.size / 1024
		}
		prev_net = now

		s = 00
		# cpu
		now = cpu_stat
		t = prev_cpu.zip(now)
		total = t.inject(0) {|r,(pr,nw)| r + pr - nw}
		t.pop
		load  = t.inject(0) {|r,(pr,nw)| r + pr - nw} / total.to_f * 100
		load  = load.abs

		puts "%.1f%% d:% 5.1fKB/s u:% 5.1fKB/s" % [load, down, up]

		prev_cpu = now
	end
when /darwin/
	loop do
		sleep 1
	end
end
