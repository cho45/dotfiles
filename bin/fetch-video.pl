#!/usr/bin/perl
# original: http://search.cpan.org/src/MIYAGAWA/WWW-NicoVideo-Download-0.01/eg/fetch-video.pl

use strict;
use WWW::NicoVideo::Download;
use Term::ProgressBar;
use Config::Pit;
use URI;
use HTML::TreeBuilder::XPath;
use Perl6::Say;
use Getopt::Long;

my $opts = {
	allow_low  => 0,
	force      => 0,
};
GetOptions(
	"lowmode" => \$opts->{allow_low},
	"force"   => \$opts->{force},
);

my $config = pit_get("nicovideo.jp", require => {
	"username" => "email of nicovideo.jp",
	"password" => "password of nicovideo.jp",
});

my $video_id   = shift @ARGV;
die "Usage: $0 url" unless $video_id;

if ($video_id =~ /^http/) {
	($video_id) = $video_id =~ qr|/([^/]+)$|;
}

my $url = "http://www.nicovideo.jp/watch/$video_id";

say STDERR "Video ID: $video_id";

my ($term, $fh, $name);

my $client = WWW::NicoVideo::Download->new( email => $config->{username}, password => $config->{password} );
my $res = $client->user_agent->get($url);
if ($res->is_success) {
	my $tree = HTML::TreeBuilder::XPath->new_from_content($res->content);
	my $title = $tree->findvalue("//h1");
	say STDERR "Title: $title";

	$title =~ s{[/:]}{_}g;

	$name = "$title.$video_id";
} else {
	say STDERR "Unknown Title;";
	$name = $video_id;
}


my $url = $client->prepare_download($video_id);
my $is_low = ($url =~ /low/);
if ($is_low) {
	say STDERR "! Low-Mode";
	exit 1 unless $opts->{lowmode};
}

my $res = $client->user_agent->request( HTTP::Request->new( GET => $url ), sub {
	my ($data, $res, $proto) = @_;

	unless ($term && $fh) {
		my $ext = (split '/', $res->header('Content-Type'))[-1] || "flv";
		$ext = "swf" if $ext =~ /flash/;

		my $fn = $is_low ? "$name.low.$ext" : "$name.$ext";
		$fn =~ s/:/_/g;

		say STDERR "Filename: $fn";

		if (-e $fn && !$opts->{force}) {
			say STDERR "File already exists";
			exit 0;
		}

		open $fh, ">", $fn or die $!;
		$term = Term::ProgressBar->new( $res->header('Content-Length') );
	}

	$term->update( $term->last_update + length $data );
	print $fh $data;
});

