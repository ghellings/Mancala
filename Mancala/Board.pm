package Mancala::Board;
use strict;
use warnings;
use Tie::Cycle;
use Data::Dumper;
use Carp;
use Moose;
with qw{MooseX::Clone};

has 'house1'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house2'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house3'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house4'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house5'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house6'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house7'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house8'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house9'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house10'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house11'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'house12'		=> ( 'is' => 'rw', isa => 'Int', default => 4, traits => [qw{Clone}], );
has 'player'		=> ( 'is' => 'rw', isa => 'Mancala::Player');
has 'player1'		=> ( 'is' => 'ro', isa => 'Mancala::Player');
has 'player2'		=> ( 'is' => 'ro', isa => 'Mancala::Player');
has 'wincondition'	=> ( 'is' => 'rw', isa => 'Int' );
has '_lasthouse'	=> ( 'is' => 'rw', isa => 'Str');
no Moose;

sub error {
	my ($self,$error) = @_;
	$self->{'_error'} .= $error."\n" if $error;
	return $self->{'_error'};
}
sub clear_error {
	my $self = shift;
	$self->{'_error'} = undef;
}

# Handle moving seeds around board and deal with legal moves
sub move {
	my ($self,$house,$player,$nocheck) = @_;
	carp "Not a Mancala::Player" unless ref $player eq 'Mancala::Player';
	my $start_house = "house$house";
	
	my $seeds;
	# get the number of seeds in house
	unless($nocheck) {
		# check if choosen house is a valid house for player to play from
		unless ( grep /^$start_house$/, ($self->player_houses($player)) ) {
			$self->error("Not a valid move for ".$self->player->name);
			return;
		} 
		# ensure seeds are in house selected
		$seeds = $self->$start_house();
		$self->error("No seeds in house") unless $seeds;

		my $valid_moves;
		# check a list of valid moves;
		$valid_moves = $self->possible_feed;
		# if there are not valid moves and the other player's houses are empty this player loses
		if (! keys %$valid_moves && $self->player_houses_empty($self->other_player)) {
			$self->wincondition(1);
			return;
		}
		unless ( $self->error ) {
			$self->error("Move leaves opponent empty") unless $valid_moves->{$start_house};
		}
		return if $self->error;
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

# Score moves
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

# Return hash of seed counts for all houses on board
sub whole_board {
	my $self = shift;
	my $board;
	map { my $h = "house$_"; $board->{$h} = $self->$h(); } 1..12;
	return $board; 
}

# Clone the board, try all possible moves for current player and return valid moves that
# don't leave the opponent houses empty
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

# Return opponent of current player
sub other_player {
	my $self = shift;
	if ($self->player->position == 1) {
		return $self->player2;
	}
	else {
		return $self->player1;
	}
}

# Return the houses owned by player you pass to it
sub player_houses {
	my ($self,$player) = @_;
	carp "Not a Mancala::Player" unless ref $player eq 'Mancala::Player';
	my @houses = $player->position == 1 ? map "house$_", 1..6 : map "house$_", 7..12;
	return @houses;
}

# Return true if players houses are all empty
sub player_houses_empty {
	my ($self,$player) = @_;
	carp "Not a Mancala::Player" unless ref $player eq 'Mancala::Player';
	my $count;
	map $count += $self->$_, $self->player_houses($player);
	return if $count;
	return 1;
}


1;

