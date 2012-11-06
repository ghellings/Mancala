#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Mancala::Game;
use Mancala::Player;

my $player1 = Mancala::Player->new( name => "player1", position => "1");
my $player2 = Mancala::Player->new( name => "player2", position => "2");

my $game = Mancala::Game->new( player1 => $player1, player2 => $player2);

$game->play;

