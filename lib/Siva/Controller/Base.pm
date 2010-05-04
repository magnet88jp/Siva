package Siva::Controller::Base;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Data::Page::Navigation;

sub list :Local {
    my ($self, $c, $cnd, $opt) = @_;
    my $path = $c->req->path;
    $c->stash->{path} = Siva::Logic::Util->getBasePathName($path);
    my $bt = Siva::Logic::Util->getBaseTemplateName($path);
    $c->stash->{template} = $bt.'/list.tt2';
    my %search_cnd = keys(%$cnd) ? %$cnd : ();
    my %search_opt = keys(%$opt) ? %$opt : ();
    $search_opt{page} = $search_opt{page} || $c->req->param('page') || 1;
    $search_opt{rows} = $search_opt{rows} || $c->req->param('rows') || 10;
    $search_opt{order_by} = $search_opt{order_by} || 'id';
    my $bm = Siva::Logic::Util->getBaseModelName($path);
    $c->stash->{model} = $c->model('DBIC')->resultset($bm)->search({%search_cnd}, {%search_opt});
}

sub show :LocalRegex('^(\d+)$') {
    my ($self, $c) = @_;
    my $id = $c->req->captures->[0];
    my $path = $c->req->path;
    $c->stash->{path} = Siva::Logic::Util->getBasePathName($path);
    my $bm = Siva::Logic::Util->getBaseModelName($path);
    $c->stash->{model} = $c->model('DBIC')->resultset($bm)->find($id);
    my $bt = Siva::Logic::Util->getBaseTemplateName($path);
    $c->stash->{template} = $bt.'/show.tt2';
}

1;
