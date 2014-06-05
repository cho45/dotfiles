#!/usr/bin/ruby
# coding: utf-8:

require "drb/drb"
require "thread"
require "logger"
require "timeout"

class Backtick
	NAME = "backtick"

	attr_reader :logger

	def self.instance
		@@instance ||= self.new
	end

	def initialize
		$stdout.sync = true
		@logger       = $stdout.tty?? Logger.new($stdout) : Logger.new(File.expand_path('~/.screen/backtick.log'))
		@logger.level = Logger::DEBUG
		@logger.info ENV.inspect
		self.status   = ''
	end

	def status=(new)
		status = "#{self.header} #{new}"
		@logger.info "status: #{status}"
		$0 = status
	end

	def header
		"#{NAME}"
	end

	def start
		case RUBY_PLATFORM
		when /linux/
			stats = []
			prev_net = network
			prev_cpu = cpu_stat

			loop do
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

				puts "%.1f%% DOWN:%.1fKB/s UP:%.1fKB/s" % [load, down, up]

				prev_cpu = now

				sleep 3
			end
		else
			loop do
				sleep 3
			end
		end
	end

	def network
		s = File.readlines("/proc/net/dev").detect {|i| i[/^\s*eth0/]}.split(/:|\s+/)
		[s[2].to_i, s[10].to_i]
	end

	def cpu_stat
		_, *s = *File.read("/proc/stat").match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
		s.collect {|i| i.to_i}
	end
end

Backtick.instance.start

