package Mancala::Player;
use strict;
use warnings;
use Data::Dumper;
use namespace::autoclean;
use Moose;

with qw{MooseX::Clone};

=head1 NAME

Mancala::Game

=head1 DESCRIPTION

Player the game Mancala

=head1 METHODS

=cut


=head2 name

=cut

has	'name'		=>	( is => 'ro', isa => 'Str', required => 1, traits => [qw{Clone}]);


=head2 position

=cut

has	'position'	=>	( is => 'rw', isa => 'Int', required => 1, traits => [qw{Clone}]);


=head2 points

=cut

has	'points'	=>	( is => 'rw', isa => 'Int', default => 0, traits => [qw{Clone}]);


=head2 playerid

=cut

has 'playerid'  =>  ( is => 'rw', isa => 'Str', traits => [qw{Clone}]);


=head1 AUTHOR

Greg Hellings

=head1 LICENSE

This library is free sofrware.  You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


__PACKAGE__->meta->make_immutable;

1;
