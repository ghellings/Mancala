package Mancala::Game;
use strict;
use warnings;
use Mancala::Board;
use Data::Dumper;

use Moose;
has 'player1'	=> ( is => 'ro', isa => 'Mancala::Player', required => 1 );
has 'player2'	=> ( is => 'ro', isa => 'Mancala::Player', required => 1 );
has 'board'	=> ( is => 'ro', isa => 'Mancala::Board', lazy => 1, builder => '_board');
has 'turn'	=> ( is => 'rw', isa => 'Mancala::Player' );
no Moose;

sub _board {
	my $self = shift;
	my $board = Mancala::Board->new(player1 => $self->player1, player2 => $self->player2);
	return $board;
}

sub play {
	my $self = shift;
	$self->turn($self->player1) unless $self->turn;
	my $gameover;
	while ( ! $gameover ) {
		$self->print_board;
		$self->print_scores;
		my $valid_input;
		do {
			$self->board->clear_error;	
			print $self->turn->name.", select a move\n";
			my $input = <>;
			chomp $input;
			$valid_input = $self->board->move($input,$self->turn);
			print $self->board->error unless $valid_input;
		} until ($valid_input);
		$self->print_board;
		my $score = $self->board->score($self->turn);
		$gameover = 1 if $self->turn->points >= 25;
		next if $score;
		$self->change_player_turn;
	}
	$self->print_scores;
}

sub change_player_turn {
	my $self = shift;
	if ( $self->turn == $self->player1 ) {
		$self->turn($self->player2);
	}
	else {
		$self->turn($self->player1);
	}
	return $self->turn;
}

sub print_board {
	my $self = shift;
	my $board = $self->board->whole_board;
	my ($da,$db);
	my @loop = ([1,12],[2,11],[3,10],[4,9],[5,8],[6,7]);
	foreach my $pair ( @loop ) { 
		my ($a,$b) = map { "house$_" } @{$pair}; 
		printf "%-10s [% 2s]\t%-10s [% 2s]\n",  $a, $self->board->$a, $b, $self->board->$b; 
	}  
}

sub print_scores {
	my $self = shift;
	print "Player 1: ".$self->player1->points."\n";
	print "Player 2: ".$self->player2->points."\n";
}

1;
