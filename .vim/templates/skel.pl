#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
sub p ($) { warn Dumper shift }

use Perl6::Say;

use lib glob 'modules/*/lib';
use lib 'lib';


