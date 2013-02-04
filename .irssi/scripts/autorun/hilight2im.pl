use strict;
use warnings;

use Irssi;
use POSIX ();

use LWP::UserAgent;
use HTTP::Request::Common;
use Digest::SHA1 qw/sha1_hex/;
use URI;
use URI::Escape;

use Email::MIME;
use Email::MIME::Creator;
use Email::Send;

our $VERSION = '0.1';

our %IRSSI = (
    name        => 'hilight2im',
);

sub notify {
    my ($message) = @_;

    my ($channel) = ($message =~ /(#[^\s:<>]+)/);

    my $uri = URI->new("http://irssw.cho45.stfuawsc.com/$channel");

    my $subject = $message;
    my $body = join("\n", $message, $uri);

    my $mail = Email::MIME->create(
        header => [
            From    => 'cho45@lowreal.net',
            To      => 'cho45@lowreal.net',
            Subject => $subject,
        ],
        attributes => {
            content_type => "text/plain; charset=utf-8"
        },
        body  => $body
    );

    my $sender = Email::Send->new({ mailer => 'SMTP' });
    $sender->send($mail);
}

our $prev_text = "";
sub sig_printtext {
    my ($dest, $text, $stripped) = @_;

    if ( $dest->{level} & MSGLEVEL_HILIGHT ) {
        return if $text eq $prev_text;

        $stripped =~ s/\s/ /g;
        return if $stripped =~ /<[@ +~]+cho45>/;
        return if $stripped =~ / \* cho45/;
        $prev_text = $text;

        my $pid = fork;
        if ($pid) {
            Irssi::pidwait_add($pid);
        }
        elsif (defined $pid) {
            notify(sprintf "[irssi] %s: %s", $dest->{target}, $stripped);
            POSIX::_exit(1);
        }
    }
}
Irssi::signal_add('print text' => \&sig_printtext);

