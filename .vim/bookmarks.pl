use strict;
use warnings;

use XML::Feed;
use URI;
use Perl6::Say;
use Cache::File;
use URI::Fetch;

my $target = 'http://b.hatena.ne.jp/hotentry.rss';

my $cache = Cache::File->new( cache_root => '/tmp/cache' );
my $res = URI::Fetch->fetch(
    $target,
    Cache => $cache
) or die URI::Fetch->errstr;

my $feed = XML::Feed->parse(\($res->content));

for my $entry ($feed->entries) {
    say sprintf("%s\tcall system('open %s')", $entry->title, $entry->link);
}
