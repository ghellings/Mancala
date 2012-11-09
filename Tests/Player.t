#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use lib q{../};

# Test 1
BEGIN { use_ok('Mancala::Player') };

# Test 2
require_ok('Mancala::Player');

# Test 3
my $player = Mancala::Player->new(name => q{Player}, position => q{1});
isa_ok( $player, q{Mancala::Player});


# Test 4
$player->points(1);
ok( $player->points == 1, q{Player scoring ok});
done_testing();
