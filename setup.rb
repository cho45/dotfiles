#!/usr/bin/env ruby
#
# Create:
# ~/
#   bin/
#     sometools (symlinks)
#   dotfiles/
#     foobar
#   coderepos/
#     foobar

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


cd "~".expand

if "dotfiles".expand.exist?
	cd "dotfiles"
#	sh "git pull"
else
	sh "git clone git@github.com:cho45/dotfiles.git dotfiles"
	cd "dotfiles"
end

"bin".expand.mkpath
Dir["bin/*"].each do |f|
	link f, "~/bin"
end

link ".vimrc", "~/.vimrc"
link ".gvimrc", "~/.gvimrc"
link ".vim", "~/.vim"

link ".zshrc", "~/.zshrc"
link ".zsh", "~/.zsh"

link ".bashrc", "~/.bashrc"

link ".screenrc", "~/.screenrc"
link ".screen", "~/.screen"

link ".bvirc", "~/.bvirc"

link ".gemrc", "~/.gemrc"

link "git/.gitconfig", "~/.gitconfig"
link "git/.gitignore", "~/.gitignore"

if RUBY_PLATFORM =~ /darwin/
	link "/Applications/Firefox.app/Contents/MacOS/firefox", "~/bin"
	link "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "~/bin/chrome"
end

