#!/usr/bin/perl
# original: http://search.cpan.org/src/MIYAGAWA/WWW-NicoVideo-Download-0.01/eg/fetch-video.pl

use strict;
use WWW::NicoVideo::Download;
use Term::ProgressBar;
use Config::Pit;
use URI;
use HTML::TreeBuilder::XPath;
use Perl6::Say;

my $config = pit_get("nicovideo.jp", require => {
	"username" => "email of nicovideo.jp",
	"password" => "password of nicovideo.jp",
});

my $url        = shift @ARGV;
die "Usage: $0 url" unless $url;
my ($video_id) = $url =~ qr|/([^/]+)$|;

say STDERR "Video ID: $video_id";

my ($term, $fh, $name);

my $client = WWW::NicoVideo::Download->new( email => $config->{username}, password => $config->{password} );
my $res = $client->user_agent->get($url);
if ($res->is_success) {
	my $tree = HTML::TreeBuilder::XPath->new_from_content($res->content);
	my $title = $tree->findvalue("//h1");
	say STDERR "Title: $title";
	$name = "$title.$video_id";
} else {
	say STDERR "Unknown Title;";
	$name = $video_id;
}


my $url = $client->prepare_download($video_id);
if ($url =~ /low/) {
	say STDERR "! Low-Mode";
}

my $res = $client->user_agent->request( HTTP::Request->new( GET => $url ), sub {
	my ($data, $res, $proto) = @_;

	unless ($term && $fh) {
		my $ext = (split '/', $res->header('Content-Type'))[-1] || "flv";
		$ext = "swf" if $ext =~ /flash/;

		my $fn = "$name.$ext";
		$fn =~ s/:/_/g;

		say STDERR "Filename: $fn";

		open $fh, ">", $fn or die $!;
		$term = Term::ProgressBar->new( $res->header('Content-Length') );
	}

	$term->update( $term->last_update + length $data );
	print $fh $data;
});

