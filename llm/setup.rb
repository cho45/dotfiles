#!/usr/bin/env ruby

require "pathname"
require "fileutils"
include FileUtils::Verbose

class String
	def expand
		ret = Pathname.new(self).expand_path
		ret.parent.mkpath unless ret.parent.exist?
		ret
	end
end

def sh(*args)
	puts args.join(" ")
	system(*args)
end

def link(src, dst)
	puts "#{src} =>\n\t#{dst}"
	src = Pathname.new(src).expand_path
	dst = Pathname.new(dst).expand_path
	dst.parent.mkpath unless dst.parent.exist?
	remove_file dst if dst.symlink?
	remove_file dst if dst.file?
	ln_sf src.to_s, dst.to_s
end

def which(bin)
	ENV['PATH'].split(/:/).map {|i| File.join(i, bin) }.find {|i| File.exist?(i) }
end

def with(bin, &block)
	if which(bin)
		yield
	else
		puts "** #{bin} is not found in path"
	end
end

unless which('git')
	puts "Install git first. exit..."
	exit 1
end



cd __dir__.expand

link "./rules/principal.md", "~/.claude/CLAUDE.md"
link "./rules/principal.md", "~/.gemini/GEMINI.md"
link "./rules/principal.md", "~/.kilocode/rules/principal.md"

link "./skills", "~/.claude/skills"
link "./skills", "~/.gemini/skills"
link "./skills", "~/.kilocode/skills"


