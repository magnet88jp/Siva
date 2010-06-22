package Siva;

use strict;
use warnings;

use Siva::Logic::Util;

#
# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
# Static::Simple: will serve static files from the application's root 
# directory
#
use Catalyst qw/-Debug ConfigLoader Static::Simple/;

our $VERSION = '0.01';

#
# Start the application
#
__PACKAGE__->setup;

=head1 NAME

Siva - Catalyst based application

=head1 SYNOPSIS

    script/siva_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=cut

=head2 default

=cut

#
# Output a friendly welcome message
#
sub default : Private {
    my ( $self, $c ) = @_;

    # Hello World
#    $c->response->body( $c->welcome_message );
    $c->res->body('redirect');
    $c->res->redirect('/top', 303);
}

sub top : Global {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'top.tt2';
}

#
# Uncomment and modify this end action after adding a View component
#
#=head2 end
#
#=cut
#
#sub end : Private {
#    my ( $self, $c ) = @_;
#
#    # Forward to View unless response body is already defined
#    $c->forward( $c->view('') ) unless $c->response->body;
#}

sub end : Private {
    my ( $self, $c ) = @_;

    # Forward to View unless response body is already defined
    $c->forward( $c->view('TT') ) unless $c->response->body;
}

=head1 AUTHOR

nishino

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
