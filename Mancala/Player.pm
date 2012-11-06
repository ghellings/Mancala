package Mancala::Player;
use strict;
use warnings;
use Data::Dumper;

use Moose;
has	'name'		=>	( is => 'ro', isa => 'Str', required => 1);
has	'position'	=>	( is => 'ro', isa => 'Int', required => 1);
has	'points'	=>	( is => 'rw', isa => 'Int', default => 0 );
no Moose;

1;
