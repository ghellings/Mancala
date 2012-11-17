#!/usr/bin/env perl
use strict;
use warnings;
use lib '../';
use Data::Dumper;
use Test::More;
use Mancala::Player;

# Test 1
BEGIN{ use_ok('Mancala::Game')};

# Test 2
require_ok('Mancala::Game');

# Test 3
my $player1 = Mancala::Player->new(name => 'Player1', position => 1);
my $player2 = Mancala::Player->new(name => 'Player2', position => 2);
my $c = [
		player1		=> $player1,
		player2		=> $player2,
];
my $game = new_ok('Mancala::Game', $c);

# Test 4
my @methods = qw{ player1 player2 board turn _board play change_player_turn print_board print_scores };
can_ok($game,@methods); 

# Test 5
subtest 'Players Check' => sub {
	isa_ok($game->player1, 'Mancala::Player');
	isa_ok($game->player2, 'Mancala::Player');
	$game->turn($player1);
	isa_ok($game->turn, 'Mancala::Player');
};

# Test 6
isa_ok($game->board, 'Mancala::Board');

# Test 7
	

done_testing();
