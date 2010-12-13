use strict;
use warnings;
use Mac::AppleScript qw(RunAppleScript);
use Perl6::Say;
use FindBin;

my $me = "$0";

sub play {
    my $script = <<"SCRIPT";
        tell application "iTunes"
            play
        end tell
SCRIPT
    RunAppleScript($script);
}

sub stop {
    my $script = <<"SCRIPT";
        tell application "iTunes"
            stop
        end tell
SCRIPT
    RunAppleScript($script);
}

sub next_track {
    my $script = <<"SCRIPT";
        tell application "iTunes"
            next track
        end tell
SCRIPT
    RunAppleScript($script);
}

sub prev_track {
    my $script = <<"SCRIPT";
        tell application "iTunes"
            previous track
        end tell
SCRIPT
    RunAppleScript($script);
}

sub play_n {
    my $n = shift;
    my $script = <<"SCRIPT";
        tell application "iTunes"
            set cPlaylist to current playlist
            play track $n of cPlaylist
        end tell
SCRIPT
    RunAppleScript($script);
}

sub list {
    my $script = <<"SCRIPT";
        tell application "iTunes"
            set cPlaylist to current playlist
            set resultString to ""
            repeat with i from 1 to count of tracks in cPlaylist
                set sName to name of track i in cPlaylist
                set sArtist to artist of track i in cPlaylist
                set sTime to time of track i in cPlaylist
                set resultString to resultString & sName & "\t" & sArtist & "\t" & sTime & "\n"
            end repeat
            return resultString
        end tell
SCRIPT

    my $result = RunAppleScript($script);
    $result =~ s/^"//g;
    $result =~ s/"$//g;

    my $i = 1;
    my $songs = [ map { 
        my $vals = [split /\t/, $_];
        +{
            position => $i++,
            title    => $vals->[0],
            artist   => $vals->[1],
            time     => $vals->[2],
        };
    } split /\n/, $result ];

    for my $song (@$songs) {
        say sprintf(qq<%s(%s) - %s\tcall system('perl %s play_n %s')>, 
            $song->{title}, $song->{time}, $song->{artist},
            $me, $song->{position} 
        );
    }
}

my $mode = shift || '';

if ($mode eq 'play_n') {
    play_n(@ARGV);
}
elsif ($mode eq 'play') {
    play();
}
elsif ($mode eq 'stop') {
    stop();
}
elsif ($mode eq 'next') {
    next_track();
}
elsif ($mode eq 'prev') {
    prev_track();
}
else {
    list(@ARGV);
} 
