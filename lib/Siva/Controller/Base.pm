package Siva::Controller::Base;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Data::Page::Navigation;

sub base_list {
    my ($self, $c, $package, $cnd, $opt) = @_;
    &base_relation_list($self, $c, undef, $package, $cnd, $opt);
}

sub base_relation_list {
    my ($self, $c, $parent_id, $package, $cnd, $opt) = @_;
    $c->stash->{parent_id} = $parent_id;
    $c->stash->{path} = Siva::Logic::Util->getControllerPathName($package, $parent_id);
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    my $cname = Siva::Logic::Util->getControllerLCName($package);
    $c->stash->{template} = $cname.'/list.tt2';
    my %search_cnd = keys(%$cnd) ? %$cnd : ();
    my %search_opt = keys(%$opt) ? %$opt : ();
    $search_opt{page} = $search_opt{page} || $c->req->param('page') || 1;
    $search_opt{rows} = $search_opt{rows} || $c->req->param('rows') || 10;
    $search_opt{order_by} = $search_opt{order_by} || 'id';
    $c->stash->{model} = $c->model($sname)->search({%search_cnd}, {%search_opt});
}

1;
