
use strict;
use warnings;

use Irssi;
use vars qw($VERSION %IRSSI);

use vars qw/$prevmsg/;

$VERSION = "0.01";
%IRSSI = (
	authors     => "cho45",
	contact     => "cho45\@lowreal.net",
	name        => "all",
	description => "show all message in a window",
	license     => "Public Domain",
	url         => "http://irssi.org/",
	changed     => "2006-09-20T21:46:00+09:00"
);
$prevmsg = '';

my $windowname = Irssi::window_find_name('all');
if (!$windowname) {
	Irssi::command("window new hidden");
	Irssi::command("window name all");
}

sub print_text {
	my ($dest, $text, $stripped) = @_;
	my $window = Irssi::window_find_name('all');

	return if $dest->{level} & MSGLEVEL_CLIENTCRAP;
	return if !$window;

	if ($dest->{level} & (
		MSGLEVEL_PUBLIC  |
		MSGLEVEL_NOTICES |
		MSGLEVEL_SNOTES  |
		MSGLEVEL_ACTIONS |
		MSGLEVEL_INVITES
	)) {
		my $n = $dest->{window}->{refnum};
		my $c = $dest->{target};
		$text =~ s/%/%%/g;
		$text =  sprintf "[%2d]%s:%s", $n, $c, $text;


		$window->print($text, MSGLEVEL_CLIENTCRAP) unless $prevmsg eq $text;
		$prevmsg = $text;
	}
}
Irssi::signal_add('print text', 'print_text');

