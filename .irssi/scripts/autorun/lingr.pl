use strict;
use warnings;
use Encode;

use AnyEvent;
use AnyEvent::Lingr;
use Scalar::Util ();

use Irssi;

our %IRSSI = ( name => 'lingr' );

our $lingr;
my %NICKMAP;

sub cmd_base {
    my ($data, $server, $item) = @_;
    Irssi::command_runsub('lingr', $data, $server, $item);
}

sub cmd_start {
    if ($lingr) {
        Irssi::print("Lingr: ERROR: lingr session is already running");
        return;
    }

    my $user     = Irssi::settings_get_str('lingr_user');
    my $password = Irssi::settings_get_str('lingr_password');
    my $api_key  = Irssi::settings_get_str('lingr_apikey');

    unless ($user and $password) {
        Irssi::print("Lingr: lingr_user and lingr_password are required to /set");
        return;
    }

    $lingr = AnyEvent::Lingr->new(
        user     => $user,
        password => $password,
        $api_key ? (api_key => $api_key) : (),
    );

    $lingr->on_error(sub {
        my ($msg) = @_;
        return unless $lingr;

        if ($msg =~ /^596:/) {  # timeout
            $lingr->start_session;
        }
        else {
            Irssi::print("Lingr: ERROR: " . $msg);
            my $t; $t = AnyEvent->timer(
                after => 5,
                cb => sub {
                    undef $t;
                    $lingr->start_session if $lingr;
                },
            );
        }
    });

    $lingr->on_room_info(sub {
        my ($rooms) = @_;
        return unless $lingr;

        %NICKMAP = ();

        for my $room (@$rooms) {
            my $win_name = 'lingr/' . $room->{id};
            my $win = Irssi::window_find_name($win_name);
            unless ($win) {
                Irssi::print("Lingr: creating window: " . $win_name);
                $win = Irssi::Windowitem::window_create(undef, 1);
                $win->set_name($win_name);
            }

            for my $member (@{ $room->{roster}{members} }) {
                $NICKMAP{ $room->{id} }{ $member->{username} } = $member;
            }
        }

        Irssi::print("Lingr: session_started");
    });

    $lingr->on_event(sub {
        my ($event) = @_;

        if (my $msg = $event->{message}) {
            my $win_name = 'lingr/' . $msg->{room};
            my $win = Irssi::window_find_name($win_name);

            # strip trailing new lines
            (my $text = encode_utf8($msg->{text})) =~ s/(\r?\n)+$//s;

            if ($win) {
                if ($msg->{type} eq 'user') {
                    my $member = $NICKMAP{ $msg->{room} }{ $msg->{speaker_id} };
                    my $is_owner;
                    if ($member) {
                        $is_owner = $member->{is_owner};
                    }

                    $win->printformat(
                        MSGLEVEL_PUBLIC,
                        $msg->{speaker_id} eq $lingr->user ? 'ownmsg' : 'pubmsg',
                        $msg->{speaker_id}, $text,
                        $is_owner ? '@' : ' ');
                }
                else {
                    $win->printformat(MSGLEVEL_NOTICES, 'notice_public',
                                      $msg->{speaker_id}, $msg->{room}, $text);
                }
            }
        }
        elsif (my $presence = $event->{presence}) {
            my $win_name = 'lingr/' . $presence->{room};
            my $win = Irssi::window_find_name($win_name);

            if ($win) {
                if ($presence->{status} eq 'online') {
                    $NICKMAP{ $presence->{room} }{ $presence->{username} } = {
                        speaker_id => $presence->{username},
                        %$presence,
                    };

                    $win->printformat(
                        MSGLEVEL_JOINS, 'join',
                        $presence->{nickname}, $presence->{username}, $presence->{room},
                    );
                }
                elsif ($presence->{status} eq 'offline') {
                    delete $NICKMAP{ $presence->{room} }{ $presence->{username} };

                    $win->printformat(
                        MSGLEVEL_PARTS, 'part',
                        $presence->{nickname}, $presence->{username}, $presence->{room}, '',
                    );
                }
            }
        }
    });

    $lingr->start_session;
}

sub cmd_stop {
    undef $lingr;
}

sub sig_send_text {
    my ($line, $server, $win) = @_;

    if (!$win) {
        $win = Irssi::active_win();
    }

    my ($room) = $win->{name} =~ m!^lingr/(.*)$!;
    if ($room && $lingr) {
        $lingr->say(decode_utf8($room), decode_utf8($line));
    }
}

sub sig_complete_word {
    my ($strings, $win, $word, $linestart, $want_space) = @_;

    unless ($win) {
        $win = Irssi::active_win();
    }

    my ($room) = $win->{name} =~ m!^lingr/(.*)$!;
    if ($room and $word !~ m!^/!) {
        push @$strings, map { '@' . $_ } sort grep /^$word/i, keys %{ $NICKMAP{$room} };
        $$want_space = 1;
        Irssi::signal_stop();
    }
}

sub cmd_update_room_info {
    unless ($lingr) {
        Irssi::print("Lingr: ERROR: lingr session does not started");
        return;
    }

    $lingr->update_room_info;
}

sub cmd_update_theme {
    Irssi::theme_register([
        'pubmsg'        => Irssi::current_theme()->get_format('fe-common/core', 'pubmsg'),
        'ownmsg'        => Irssi::current_theme()->get_format('fe-common/core', 'own_msg'),
        'notice_public' => Irssi::current_theme()->get_format('fe-common/irc', 'notice_public'),
        'join'          => Irssi::current_theme()->get_format('fe-common/core', 'join'),
        'part'          => Irssi::current_theme()->get_format('fe-common/core', 'part'),
    ]);
}
cmd_update_theme();

Irssi::command_bind('lingr', \&cmd_base);
Irssi::command_bind('lingr start', \&cmd_start);
Irssi::command_bind('lingr stop', \&cmd_stop);
Irssi::command_bind('lingr update_theme', \&cmd_update_theme);
Irssi::command_bind('lingr update_room_info', \&cmd_update_room_info);

Irssi::settings_add_str('lingr', 'lingr_user', q[]);
Irssi::settings_add_str('lingr', 'lingr_password', q[]);
Irssi::settings_add_str('lingr', 'lingr_apikey', q[]);

Irssi::signal_add_last('send text', \&sig_send_text);
Irssi::signal_add_first('complete word', \&sig_complete_word);
