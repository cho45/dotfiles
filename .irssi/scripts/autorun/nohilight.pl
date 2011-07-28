use strict;
use warnings;
# nohilight.pl is for ignoring hilight mistake.
#
# You can use this for hilight 'foobar' but ignoring 'foobarbaz'.
#
# Usage:
# /nohilight
#   Show current nohilight list.
# /nohilight add <text>
#   Append new nohilight.
# /nohilight del [n]
#   Remove `n` nohilight.
#

use Irssi;
use POSIX ();
use utf8;

use LWP::UserAgent;
use HTTP::Request::Common;
use Digest::SHA1 qw/sha1_hex/;
use URI;
use URI::Escape;

our $VERSION = '0.1';

our %IRSSI = (
	name        => 'nohilight',
	description => 'setting ignore hilight',
	authors     => 'cho45',
);

Irssi::settings_add_str('nohilight' => 'nohilight', '');

our $nohilight;

sub load {
	[ split /\|/, (Irssi::settings_get_str('nohilight') || '') ];
}

sub save {
	Irssi::settings_set_str('nohilight' => join '|', @$nohilight);
}


$nohilight = load();

Irssi::signal_add_first('print text', sub {
	my ($dest, $text, $stripped) = @_;
	return unless $dest->{level} & MSGLEVEL_HILIGHT;
	my $regexp = join '|', @$nohilight;
	if ($stripped =~ /$regexp/ || $dest->{target} =~ /$regexp/) {
		$dest->{level} ^= MSGLEVEL_HILIGHT;
		$dest->{level} |= MSGLEVEL_NOHILIGHT;
		$dest->{window}->print($text, $dest->{level});
		Irssi::signal_stop;
	}
});

Irssi::command_bind('nohilight', sub {
	my ($data, $server, $witem) = @_;
	my ($act, $arg) = split /\s+/, $data, 2;
	local $_ = $act || '';

	/add/ and return do {
		push @$nohilight, $arg;
		save();
		Irssi::print('Added Nohilight: ' . $arg, MSGLEVEL_CLIENTCRAP);
	};

	/del|re?m/ and return do {
		my $r = $arg ? splice(@$nohilight, $arg - 1, 1) : pop(@$nohilight);
		save();
		Irssi::print('Removed Nohilight: ' . $r, MSGLEVEL_CLIENTCRAP);
	};

	Irssi::print('Nohilights:', MSGLEVEL_CLIENTCRAP);
	my $i = 1;
	for (@$nohilight) {
		Irssi::print(sprintf('% 4d %s', $i++, $_), MSGLEVEL_CLIENTCRAP);
	}
});

