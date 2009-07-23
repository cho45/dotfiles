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
"bin".expand.mkpath


#sh *%w{svn co -N http://svn.coderepos.org/share coderepos}
cd "coderepos" do
	sh *%w{svn up -N lang}
	cd "lang" do
		sh *%w{svn up -N ruby}
		cd "ruby" do
			sh *%w{svn up misc}
			cd "misc" do
				link "svnwrapper.rb", "~/bin"
				link "fotosho.rb", "~/bin"
			end
		end

		sh *%w{svn up -N perl}
		cd "perl" do
			sh *%w{svn up misc}
			cd "misc" do
				link "pmsetup/cho45-pmsetup", "~/bin/pmsetup"
			end
		end

		sh *%w{svn up -N zsh}
		cd "zsh" do
			sh *%w{svn up cdd}
		end
	end

	sh *%w{svn up -N dotfiles}
	cd "dotfiles" do
		sh *%w{svn up -N cutagem}
		cd "cutagem" do
			sh *%w{svn up -N templates}
			cd "templates" do
				sh *%w{svn up cho45-default}
				link "cho45-default", "~/.cutagem/templates/default"
			end
		end

		sh *%w{svn up -N vim}
		cd "vim" do
			sh *%w{svn up cho45}
			cd "cho45" do
				link ".vimrc", "~/.vimrc"
				link ".gvimrc", "~/.gvimrc"
				link ".vim", "~/.vim"
				link "sortcss", "~/bin"
			end
		end

		sh *%w{svn up -N zsh}
		cd "zsh" do
			sh *%w{svn up cho45}
			cd "cho45" do
				link ".zshrc", "~/.zshrc"
				link ".zsh", "~/.zsh"
			end
		end

		sh *%w{svn up -N bash}
		cd "bash" do
			sh *%w{svn up cho45}
			cd "cho45" do
				link ".bashrc", "~/.bashrc"
			end
		end

		sh *%w{svn up -N screen}
		cd "screen" do
			sh *%w{svn up cho45}
			cd "cho45" do
				link ".screenrc", "~/.screenrc"
				link ".screen", "~/.screen"
			end
		end

		sh *%w{svn up -N bvi}
		cd "bvi" do
			link "cho45-bvirc", "~/.bvirc"
		end

		sh *%w{svn up -N rubygems}
		cd "rubygems" do
			link "cho45-gemrc", "~/.gemrc"
		end

		sh *%w{svn up -N git}
		cd "git" do
			link "cho45-gitconfig", "~/.gitconfig"
			link "cho45-gitignore", "~/.gitignore"
		end
	end
end

if RUBY_PLATFORM =~ /darwin/
	link "/Applications/Firefox.app/Contents/MacOS/firefox", "~/bin"
end

