package Mancala::Game;
use strict;
use warnings;
use Mancala::Board;
use Moose;
use MooseX::Storage;
use namespace::autoclean;
use Data::Dumper;

with qw{MooseX::Clone}, Storage( format => 'JSON', traits => [ qw| OnlyWhenBuilt | ] ), qw{MooseX::Clone};

=head1 NAME

Mancala::Game

=head1 DESCRIPTION

Player the game Mancala

=head1 METHODS

=cut


=head2 player1

=cut

has 'player1'	=> ( is => 'ro', isa => 'Mancala::Player', required => 1, traits => [qw{Clone}]);

=head2 player2


=cut

has 'player2'	=> ( is => 'ro', isa => 'Mancala::Player', required => 1, traits => [qw{Clone}]);

=head2 board


=cut

has 'board'	    => ( is => 'ro', isa => 'Mancala::Board', lazy => 1, builder => '_board'), traits => [qw{Clone}];

=head2 turn


=cut

has 'turn'	    => ( is => 'rw', isa => 'Mancala::Player', traits => [qw{Clone}]);


=head2 gameid

=cut

has 'gameid'    => ( is => 'rw', isa => 'Str', traits => [qw{Clone}]);


=head2 _board

=cut

sub _board {
	my $self = shift;
	my $board = Mancala::Board->new(player1 => $self->player1, player2 => $self->player2);
	return $board;
}


=head2 play

=cut

sub play {
	my $self = shift;
	$self->turn($self->player1) unless $self->turn;
	my $gameover;
	while ( ! $gameover ) {
		$self->print_board;
		$self->print_scores;
		$self->board->player($self->turn);
		my $valid_input;
		do {
			$self->board->clear_error;	
			print $self->turn->name.", select a move\n";
			my $input = <>;
			chomp $input;
			$valid_input = $self->board->move($input,$self->turn);
			if ($self->board->wincondition) {
				my $winner = $self->board->other_player;
				print "Game won by : ".$winner->name;
				exit;
			}
			print join "\n", @{ $self->board->error }, "\n" unless $valid_input;
		} until ($valid_input);
		$self->print_board;
		my $score = $self->board->score($self->turn);
		$gameover = 1 if $self->turn->points >= 25;
		if ($self->board->player_houses_empty($self->turn)) {
			$self->change_player_turn;
			next;
		}
		next if $score;
		$self->change_player_turn;
	}
	$self->print_scores;
}


=head2 change_player_turn

=cut

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


=head2 print_board

=cut


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


=head2 print_scores

=cut

sub print_scores {
	my $self = shift;
	print "Player 1: ".$self->player1->points."\n";
	print "Player 2: ".$self->player2->points."\n";
}


=head1 AUTHOR

Greg Hellings

=head1 LICENSE

This library is free sofrware.  You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->config( class => 'Mancala::Game' );
__PACKAGE__->meta->make_immutable;

1;
