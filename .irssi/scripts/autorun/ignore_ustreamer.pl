
use strict;
use warnings;

use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "0.01";
%IRSSI = (
	authors     => "cho45",
	contact     => "cho45\@lowreal.net",
	name        => "all",
	description => "ignore ustreamer join/part",
	license     => "Public Domain",
	url         => "http://irssi.org/",
	changed     => "2007-10-04T01:15:00+09:00"
);

sub message_join {
	my ($srv, $channel, $nick, $addr) = @_;
	Irssi::signal_stop() if $nick =~ /^ustreamer/;
}

sub message_quit {
	my ($srv, $nick, $addr, $reason) = @_;
	Irssi::signal_stop() if $nick =~ /^ustreamer/;
}

Irssi::signal_add_first("message join", "message_join") ;
Irssi::signal_add_first("message quit", "message_quit") ;

