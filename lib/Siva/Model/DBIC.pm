package Siva::Model::DBIC;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Siva::Schema',
    connect_info => [
        'dbi:Pg:dbname=Siva;host=pgsql.magnet.mydns.jp',
        'dbuser',
        'P@ssw0rd',
        
    ],
);

=head1 NAME

Siva::Model::DBIC - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<Siva>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Siva::Schema>

=head1 AUTHOR

nishino

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
