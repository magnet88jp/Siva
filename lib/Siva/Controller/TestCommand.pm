package Siva::Controller::TestCommand;

use strict;
use warnings;

use base 'Siva::Controller::Base';

=head1 NAME

Siva::Controller::Testcase - Catalyst Controller

=head1 SYNOPSIS

See L<Siva>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

#
# Uncomment and modify this or add new actions to fit your needs
#
#=head2 default
#
#=cut
#
#sub default : Private {
#    my ( $self, $c ) = @_;
#
#    # Hello World
#    $c->response->body('Siva::Controller::Testcase is on Catalyst!');
#}


=head1 AUTHOR

nishino

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub create :Local {
    my ($self, $c) = @_;
    my %data = (
      command      => $c->request->parameters->{command},
      target       => $c->request->parameters->{target},
      value        => $c->request->parameters->{value},
    );
    $self->SUPER::create( $c, \%data);
}

sub update :LocalRegex('^(\d+)\/update$') {
    my ($self, $c) = @_;
    my %data = (
      command      => $c->request->parameters->{command},
      target       => $c->request->parameters->{target},
      value        => $c->request->parameters->{value},
    );
    $self->SUPER::update( $c, \%data);
}

1;
