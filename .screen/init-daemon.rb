#!/usr/bin/env ruby

require "fileutils"
include FileUtils

# Q でとじる
# R で再起動
system("screen", "-X", "eval", "zombie QR")

system("screen", "-X", "eval", 'hardstatus alwayslastline "%-w %{.r.}%{!}%n%f%t%{dd} %+w"')
system("screen", "-X", "eval", 'backtick 0')

cd File.expand_path("~")
# daemontools 管理下に
#system("screen", "-t", "T[main]", "zsh", "-c", "tiarra --config=tiarra.conf")
#system("screen", "-t", "T[chokan]", "zsh", "-c", "tiarra --config=chokan.conf")


cd File.expand_path("~")
cd "coderepos/lang/perl/mobirc/trunk"
system("screen", "-t", "mobirc", "zsh", "-c", "DEBUG=1 ./mobirc")

cd File.expand_path("~")
cd "coderepos/lang/ruby"
system("screen")

exec("irssi") # このプロセス window:0 は irssi に

