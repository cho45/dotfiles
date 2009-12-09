#!/usr/bin/perl
#
# by Atoms

use strict;
use IO::Socket;
use LWP::UserAgent;

use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind active_win);
$VERSION = '1.0';
%IRSSI = (
    authors	=> 'Atoms',
    contact	=> 'atoms@netparks.lv',
    name	=> 'tinyurl',
    description	=> 'create a tinyurl from a long one',
    license	=> 'GPL',
);

command_bind(
    tinyurl => sub {
      my ($msg, $server, $witem) = @_;
      my $answer = tinyurl($msg);
      if ($answer) {
        print CLIENTCRAP "$answer";
        if ($witem && ($witem->{type} eq 'CHANNEL' || $witem->{type} eq 'QUERY')) {
  	      $witem->command("MSG " . $witem->{name} ." ". $answer);
        }
      }
    }
);

sub tinyurl {
	my $url = shift;
  my $ua = LWP::UserAgent->new;
  $ua->agent("tinyurl for irssi/1.0 ");
  my $req = HTTP::Request->new(POST => 'http://tinyurl.com/create.php');
  $req->content_type('application/x-www-form-urlencoded');
  $req->content("url=$url");
  my $res = $ua->request($req);

  if ($res->is_success) {
	  return get_tiny_url($res->content);
  } else {
    print CLIENTCRAP "ERROR: tinyurl: tinyurl is down or not pingable";
		return "";
	}
}

sub get_tiny_url($) {
	
	my $tiny_url_body = shift;
	$tiny_url_body =~ /(.*)(tinyurl\svalue=\")(.*)(\")(.*)/;

	return $3;
}
