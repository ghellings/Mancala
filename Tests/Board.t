#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use lib '../';
use Mancala::Player;
use Data::Dumper;

# Test 1
BEGIN{ use_ok("Mancala::Board"); }

# Test 2
require_ok("Mancala::Board");

my $player1 = Mancala::Player->new(name => "Player1", position => "1");
my $player2 = Mancala::Player->new(name => "Player2", position => "2");

# test 3
my $board = new_ok( 'Mancala::Board' => [player1 => $player1, player2 => $player2 ], q{Mancala::Board});

# Test 4
isa_ok( $board, q{Mancala::Board});

# Test 5  Can do house methods
my @houses = map {"house$_";} 1..12;
can_ok($board,@houses);

# Test 6  Can do all other methods
my @methods = qw{ move score whole_board possible_feed other_player player_houses_empty };
can_ok($board,@methods);

# Test 7  Test move method
$board->player($player1);
ok($board->move(1,$player1), q{Move player1 with checks});

# Test 8  Test move method
ok($board->move(2,$player1,0), q{Move player1 without checks});

# Test 9
subtest 'Checking houses after move' => sub {
	cmp_ok($board->house1, "==", 0, q{Checking house1 seeds after move});
	cmp_ok($board->house2, "==", 0, q{Checking house2 seeds after move});
	cmp_ok($board->house3, "==", 6, q{Checking house3 seeds after move});
	cmp_ok($board->house4, "==", 6, q{Checking house4 seeds after move});
	cmp_ok($board->house5, "==", 6, q{Checking house5 seeds after move});
	cmp_ok($board->house6, "==", 5, q{Checking house6 seeds after move});
	cmp_ok($board->house7, "==", 5, q{Checking house7 seeds after move});
	cmp_ok($board->house8, "==", 4, q{Checking house8 seeds after move});
	cmp_ok($board->house9, "==", 4, q{Checking house9 seeds after move});
	cmp_ok($board->house10, "==", 4, q{Checking house10 seeds after move});
	cmp_ok($board->house11, "==", 4, q{Checking house11 seeds after move});
	cmp_ok($board->house12, "==", 4, q{Checking house12 seeds after move});
	done_testing();
};


# Test 10
subtest 'Checking player_house method' => sub {
	{
		my @a = $board->player_houses($player1);
		my @b = map "house$_", 1..6;
		my %h;
		map $h{$_} = 2, @a;
		map $h{$_}++, @b;
		my $wrong_house = undef;
		map { $wrong_house = 1 unless $h{$_} == 3; } keys %h;
		isnt($wrong_house, 1, q{Checking player_house method for player1});
	}
	{
		my @a = $board->player_houses($player2);
		my @b = map "house$_", 7..12;
		my %h;
		map $h{$_} = 2, @a;
		map $h{$_}++, @b;
		my $wrong_house;
		map { $wrong_house = 1 unless $h{$_} == 3; } keys %h;
		isnt($wrong_house, 1, q{Checking player_house method for player2});
	}
	done_testing();
};

# Test 11
subtest 'Checking for invalid player moves' => sub {
	map {
		$board->player($player1);
		$board->clear_error;
		$board->move($_,$player1);
		like($board->error, qr/Not a valid move for Player1.*/, qq{Check for player1 moving seeds from player2's house$_});
	} 7..12;
	map {
		$board->player($player2);
		$board->clear_error;
		$board->move($_,$player2);
		my $error = $board->error || "";
		like($error, qr/Not a valid move for Player2.*/, qq{Check for player2 moving seeds from player1's house$_});
	} 1..6;
	done_testing();
};

# Test 12 houses and reset board
subtest 'Resetting board' => sub {
	map{
		$board->$_(4);
		cmp_ok($board->$_, "==", 4, "Setting and checking $_" );
	} @houses;     

};

# Test 13 
subtest 'Setup board for player_houses_empty check' => sub {
	map{
		$board->$_(0);
		cmp_ok($board->$_, "==", 0, "Setting and checking $_" );
	} @houses[0..5]; 
};

# Test 14
cmp_ok($board->player_houses_empty($player1), "==", 1, q{Checking true player_houses_empty for player1}); 

# Test 15
ok(! defined($board->player_houses_empty($player2)) , q{Checking false player_houses_empty for player2}); 

# Test 16
$board->clear_error;
$board->player($player2);
my $result = $board->move(7,$player2);
like($board->error, qr/Move leaves opponent empty/, q{Ensure player7 must feed player1});

# Test 17
map{ $board->$_(0) } @houses[7..11];
$board->player($player2);
$result = $board->possible_feed;
ok( ! keys %$result, q{Checking possible feed for player2 with no valid moves});

# Test 18
$board->house12(1);
$result = $board->possible_feed;
ok( keys %$result, q{Checking possible feed for player2 with valid moves});

# Test 19
$board->player($player1);
my $other_player = $board->other_player;
cmp_ok($other_player->name, "eq", "Player2", q{Checking other_player method});

done_testing();
