#!plackup
use strict;
use warnings;
use Plack::Builder;

my $app = sub { [ 200, [ 'Content-Type' => 'text/plain' ], [ 'hello' ] ] };

builder {
	enable "Plack::Middleware::ReverseProxy";

	$app;
};
