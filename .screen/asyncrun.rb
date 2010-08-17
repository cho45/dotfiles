#!/usr/bin/env ruby

require "drb/drb"

DRb.start_service
DRbObject.new(nil, "druby://localhost:9999").add_queue(ENV.to_hash, ARGV.join(" "))

