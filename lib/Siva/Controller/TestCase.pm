package Siva::Controller::TestCase;

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

#sub list :Local {
#    my ($self, $c) = @_;
##    $self->base_list( $c, __PACKAGE__);
##    $c->response->body( 'Hello World2!' );
#    $c->stash->{template} = 'testcase/list.tt2';
##    $c->stash->{template} = 'welcome.tt2';
#}

1;
