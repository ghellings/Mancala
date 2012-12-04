package Mancala::Board;
use strict;
use warnings;
use Tie::Cycle;
use Data::Dumper;
use Carp;
use Moose;
use MooseX::Storage;
use namespace::autoclean;

with qw{MooseX::Clone}, Storage( format => 'JSON', traits => [ qw| OnlyWhenBuilt | ] );
=head1 NAME

Mancala::Board

=head1 DESCRIPTION

Board for the game Mancala

=head1 METHODS

=cut


=head2 house1

holds count of seeds for house

=cut


has 'house1'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house2

holds count of seeds for house

=cut


has 'house2'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house3

holds count of seeds for house

=cut


has 'house3'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house4

holds count of seeds for house

=cut


has 'house4'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house5

holds count of seeds for house

=cut


has 'house5'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house6

holds count of seeds for house

=cut


has 'house6'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house7

holds count of seeds for house

=cut


has 'house7'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house8

holds count of seeds for house

=cut


has 'house8'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house9

holds count of seeds for house


=cut


has 'house9'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house10

holds count of seeds for house


=cut


has 'house10'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house11

holds count of seeds for house

=cut


has 'house11'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 house12

holds count of seeds for house

=cut


has 'house12'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );


=head2 player

Mancala::Player object for player who's turn it currently is

=cut


has 'player'		=> ( 'is' => 'rw', isa => 'Mancala::Player');


=head2 player1

Mancala::Player object for player in position 1

=cut


has 'player1'		=> ( 'is' => 'ro', isa => 'Mancala::Player');


=head2 player2

Mancala::Player object for player in postion 2

=cut


has 'player2'		=> ( 'is' => 'ro', isa => 'Mancala::Player');


=head2 wincondition

Set to true if wincondition has been met

=cut


has 'wincondition'	=> ( 'is' => 'rw', isa => 'Int' );


=head2 _lasthouse

Private - holds house of last sewn seed

=cut


has '_lasthouse'	=> ( 'is' => 'rw', isa => 'Str');


=head2 error

Collect and retrieve errors

=head3  clear_error

=head3  match_error

=head3  count_error

=head3  has_error

=head3  add_error

=cut

has 'error'     => (
    traits      =>  ['Array'],
    is          => 'ro',
    isa         => 'ArrayRef[Str]',
    default     => sub { [] },
    handles     => {
        clear_error     => 'clear',
        match_error     => 'grep',
        count_error     => 'count',
        has_error       => 'count',
        add_error       => 'push',
        getlast_error   => 'shift',
    },
);

=head2 move

Handle moving seeds around board and deal with legal moves

=cut

sub move {
	my ($self,$house,$player,$nocheck) = @_;
	carp "Not a Mancala::Player" unless ref $player eq 'Mancala::Player';
	my $start_house = "house$house";
	
	my $seeds;
	# get the number of seeds in house
	unless($nocheck) {
		# check if choosen house is a valid house for player to play from
		unless ( grep /^$start_house$/, ($self->player_houses($player)) ) {
			$self->add_error("Not a valid move for ".$self->player->name);
			return;
		} 
		# ensure seeds are in house selected
		$seeds = $self->$start_house();
		$self->add_error("No seeds in house") unless $seeds;

		my $valid_moves;
		# check a list of valid moves;
		$valid_moves = $self->possible_feed;
		# if there are not valid moves and the other player's houses are empty this player loses
		if (! keys %$valid_moves && $self->player_houses_empty($self->other_player)) {
			$self->wincondition(1);
			return;
		}
		unless ( $self->has_error ) {
			$self->add_error("Move leaves opponent empty") unless $valid_moves->{$start_house};
		}
		return if $self->has_error;
	}
	# get seeds for nocheck case
	$seeds = $self->$start_house() unless $seeds && $nocheck;
	$self->$start_house(0);
	my @loop = map { "house$_"; }  (($house+1)..12,1..($house-1));
	tie my $houses_cycle, 'Tie::Cycle', \@loop; 
	for my $seed ( 1..$seeds ) {
		my $current_house = $houses_cycle;
		$self->$current_house( $self->$current_house + 1);
	}
	$self->_lasthouse(( tied $houses_cycle)->previous);
	return $self->whole_board;
}


=head2 score

Score moves

=cut


sub score {
	my ($self,$player) = @_;
	carp "Not a Mancala::Player" unless ref $player eq 'Mancala::Player';
	print "Last house was : ". $self->_lasthouse . "\n";
	my ($current_house) = $self->_lasthouse =~ /(\d+)/;
	my $count_cond;
	if ( $player->position == 1 ) {
		return 0 if $current_house < 7;
		$count_cond = sub { return 1 if $_[0] >= 7; };
	}
	else {
		return 0 if $current_house > 6;
		$count_cond = sub { return 1 if $_[0] <= 6; };
	}
	my $total_score;
	while ( &{$count_cond}($current_house) ) {
		my $house_name = "house$current_house";
		my $score = $self->$house_name;
		if ( $score == 2 || $score == 3 ) {
			$self->$house_name(0);
			$total_score += $score;
		}
		else {
			last;
		}
		$current_house--;
		last if $current_house > 12 || $current_house < 1;
	}
	$player->points($player->points + $total_score) if $total_score;;
	return $total_score;  
}


=head2 whole_board

Return hash of seed counts for all houses on board

=cut

sub whole_board {
	my $self = shift;
	my $board;
	map { my $h = "house$_"; $board->{$h} = $self->$h(); } 1..12;
	return $board; 
}


=head2 possible_feed

Clone the board, try all possible moves for current player and return valid moves that don't leave the opponent houses empty

=cut


sub possible_feed {
	my $self = shift;
	my %valid_move;
	foreach my $house ($self->player_houses($self->player)) {
		my ($housenum) = $house =~ /house(\d+)/;
		my $copy_of_board = $self->clone;
		$copy_of_board->move($housenum,$self->player,1); 
		unless ($copy_of_board->player_houses_empty($self->other_player)) {
			$valid_move{$house} = 1;
		}
	}
	return \%valid_move;		
}


=head2 other_player

Return opponent of current player

=cut


sub other_player {
	my $self = shift;
	if ($self->player->position == 1) {
		return $self->player2;
	}
	else {
		return $self->player1;
	}
}


=head2 player_houses

Return the houses owned by player you pass to it

=cut


sub player_houses {
	my ($self,$player) = @_;
	carp "Not a Mancala::Player" unless ref $player eq 'Mancala::Player';
	my @houses = $player->position == 1 ? map "house$_", 1..6 : map "house$_", 7..12;
	return @houses;
}


=head2 player_houses_empty

Return true if players houses are all empty

=cut


sub player_houses_empty {
	my ($self,$player) = @_;
	carp "Not a Mancala::Player" unless ref $player eq 'Mancala::Player';
	my $count;
	map $count += $self->$_, $self->player_houses($player);
	return if $count;
	return 1;
}

=head1 AUTHOR

Greg Hellings

=head1 LICENSE

This library is free sofrware.  You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


__PACKAGE__->meta->make_immutable;

1;

