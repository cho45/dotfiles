#!/usr/bin/env ruby


require "drb/drb"

DRb.start_service

o = DRbObject.new(nil, "druby://localhost:9999")
o.add_queue(ENV.to_hash, ARGV.join(" "))

