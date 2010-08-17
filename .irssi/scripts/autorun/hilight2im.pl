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
    description => 'notify hilight message to IM via im.kayac.com api',
    authors     => 'Daisuke Murase',
);


sub notify {
    my ($message) = @_;

    my $username = Irssi::settings_get_str('im_kayac_com_username');
    my $password = Irssi::settings_get_str('im_kayac_com_password');
    my $authtype = Irssi::settings_get_str('im_kayac_com_authtype');

    my $method   = "notify_$authtype";
    {
        no strict 'refs';
        &$method($message, $username, $password);
    }

    my ($channel) = ($message =~ /(#[^\s:<>]+)/);

    my $uri = URI->new('http://lab.lowreal.net/keitairc/');
    $uri->query_form(
        channel => "$channel",
        auto    => 1,
    );

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

sub notify_no {
    my ($message, $username, $password) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->timeout(3);
    $ua->post("http://im.kayac.com/api/post/$username", {
        message => $message,
    });
}

sub notify_key {
    my ($message, $username, $password) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->timeout(3);
    $ua->post("http://im.kayac.com/api/post/$username", {
        message => $message,
        password => $password,
    });
}

sub notify_sig {
    my ($message, $username, $password) = @_;

    my $signature = sha1_hex($message . $password);

    my $ua = LWP::UserAgent->new;
    $ua->timeout(3);
    $ua->post("http://im.kayac.com/api/post/$username", {
        message => $message,
        sig     => $signature,
    });
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
Irssi::settings_add_str('im_kayac_com', 'im_kayac_com_username', 'username');
Irssi::settings_add_str('im_kayac_com', 'im_kayac_com_password', 'password');
Irssi::settings_add_str('im_kayac_com', 'im_kayac_com_authtype', 'no');

