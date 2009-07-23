#!/usr/bin/env ruby
# http://username@example.com/uri/of/svn
# のとき強制的にユーザをきりかえてコミットする

require "uri"

unless ARGV.grep(/^(ci|commit)$/).empty?
	url = `svn info`[/^URL: (.+)/, 1]
	unless url
		puts "Here is not checkout path."
		exit
	end
	user = URI(url).user


	if user
		ARGV.unshift *["--no-auth-cache", "--username", user]
	end

	p ARGV
end

exec("svn", *ARGV)

