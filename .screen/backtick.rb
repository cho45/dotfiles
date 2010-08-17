#!/usr/bin/ruby

require "drb/drb"
require "thread"
require "logger"

class Backtick
	NAME = "screen/backtick"

	def self.instance
		@@instance ||= self.new
	end

	def initialize
		@logger = Logger.new(File.expand_path('~/.screen/backtick.log'))
		@logger.level = Logger::DEBUG
		`/bin/ps -x -o pid=pid,command=comand`.split(/\n/).map {|i| i.strip.split(/\s+/) }.each {|pid, command|
			system "kill", pid if command.include?(NAME)
		}
		$stdout.sync = true
		$0 = NAME
	end

	def start_async_service
		@asyncrun = AsyncRun.new(@logger)
		DRb.start_service("druby://localhost:9999", @asyncrun)
		@logger.info "start_service: #{DRb.uri}"
	end

	def start
		start_async_service

		case RUBY_PLATFORM
		when /linux/
			stats = []
			prev_net = network
			prev_cpu = cpu_stat

			loop do
				sleep 1
				next if @asyncrun.running

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
		else
			loop do
				sleep 1
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


	class AsyncRun
		def initialize(logger)
			@queue   = Queue.new
			@running = false
			@logger  = logger

			Thread.start do
				@logger.info "start run_queue thread"
				loop do
					$0 = "#{NAME} waiting..."
					@logger.info "waiting queue"
					env, command = @queue.pop
					@logger.info "dequeue: #{command}"
					@running = true
					run_queue(env, command)
					@running = false
				end
			end
		end

		def add_queue(env, command)
			@logger.info "enqueue: #{command}"
			@queue << [env, command]
			true
		end

		def running
			@running
		end

		def run_queue(env, command)
			$0 = "#{NAME} #{command}"
			prev_env = ENV.to_hash
			ENV.replace(env)
			ENV["LANG"] = "C"
			Dir.chdir(env["PWD"]) do
				popen3(command) do |stdin, stdout, stderr|
					stdin.close
					out = Thread.start do
						stdout.each do |l|
							@logger.debug l.chomp
							puts l.gsub(/[^-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\]\s]/n, "#")
						end
					end
					err = Thread.start do
						stderr.each do |l|
							@logger.debug l.chomp
							puts l.gsub(/[^-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\]\s]/n, "#")
						end
					end
					out.join(60)
					err.join(60)
				end
			end
		rescue Exception => e
			@logger.error e.inspect
		ensure
			ENV.replace(prev_env)
		end

		def popen3(command)
			pw = IO.pipe
			pr = IO.pipe
			pe = IO.pipe
			pid = fork {
				pw[1].close
				STDIN.reopen(pw[0])
				pw[0].close

				pr[0].close
				STDOUT.reopen(pr[1])
				pr[1].close

				pe[0].close
				STDERR.reopen(pe[1])
				pe[1].close

				exec(command)
			}
			pw[0].close
			pr[1].close
			pe[1].close
			pw[1].sync = true
			yield pw[1], pr[0], pr[0]
		ensure
			Process.waitpid(pid)
			[pw[1], pr[0], pe[0]].each {|p| p.close unless p.closed? }
		end
	end
end

Backtick.instance.start

