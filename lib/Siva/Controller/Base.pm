package Siva::Controller::Base;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Data::Page::Navigation;

sub list :Local {
    my ($self, $c, $parent_id, $cnd, $opt) = @_;
    $c->stash->{parent_id} = $parent_id;
#    $package = __PACKAGE__ unless $package;
    
    $c->stash->{path} = Siva::Logic::Util->getControllerPathName($c->req->path, $parent_id);
    my $sname = Siva::Logic::Util->getSchemaClassName($c->req->path);
$c->log->debug("sname=".$sname);
    my $cname = Siva::Logic::Util->getControllerLCName($c->req->path);
    $c->stash->{template} = $cname.'/list.tt2';
    my %search_cnd = keys(%$cnd) ? %$cnd : ();
    my %search_opt = keys(%$opt) ? %$opt : ();
    $search_opt{page} = $search_opt{page} || $c->req->param('page') || 1;
    $search_opt{rows} = $search_opt{rows} || $c->req->param('rows') || 10;
    $search_opt{order_by} = $search_opt{order_by} || 'id';
$c->log->debug("dcreqbase=".$c->req->base);
$c->log->debug("dcreqpath=".$c->req->path);
#$c->log->debug("dcreqpathinfo=".$c->req->pathinfo);
#$c->log->debug("package=".$package);
#    $c->stash->{model} = $c->model($sname)->search({%search_cnd}, {%search_opt});
    $c->stash->{model} = $c->model('DBIC')->resultset('TestCase')->search({%search_cnd}, {%search_opt});
}

1;
