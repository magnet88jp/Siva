package Siva::Controller::Base;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Data::Page::Navigation;

sub index :Local {
    my ($self, $c) = @_;
    $c->res->body('redirect');
    $c->res->redirect('./list', 303);
}

sub list :Local {
    my ($self, $c, $cnd, $opt) = @_;
    my $path = $c->req->path;
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

sub id :LocalRegex('^(\d+)$') {
    my ($self, $c) = @_;
    my $id = $c->req->captures->[0];
    $c->res->body('redirect');
    $c->res->redirect('./'.$id.'/show', 303);
}

sub show :LocalRegex('^(\d+)\/show$') {
    my ($self, $c) = @_;
    my $id = $c->req->captures->[0];
    my $path = $c->req->path;
    my $bm = Siva::Logic::Util->getBaseModelName($path);
    $c->stash->{model} = $c->model('DBIC')->resultset($bm)->find($id);
    my $bt = Siva::Logic::Util->getBaseTemplateName($path);
    $c->stash->{template} = $bt.'/show.tt2';
}

sub post :Local {
    my ($self, $c) = @_;
    my $path = $c->req->path;
    my $bt= Siva::Logic::Util->getBaseTemplateName($path);
    $c->stash->{template} = $bt.'/post.tt2';
}

sub create :Local {
    my ($self, $c, $data) = @_;
    my $path = $c->req->path;
    my %model_data = keys(%$data) ? %$data : ();
    my $bm = Siva::Logic::Util->getBaseModelName($path);
    my $model = $c->model('DBIC')->resultset($bm)->create({%model_data});
    $c->res->body('redirect');
    $c->res->redirect('./'.$model->id.'/show', 303);
}

sub edit :LocalRegex('^(\d+)\/edit$') {
    my ($self, $c) = @_;
    my $path = $c->req->path;
    my $id = $c->req->captures->[0];
    my $bm = Siva::Logic::Util->getBaseModelName($path);
    $c->stash->{model} = $c->model('DBIC')->resultset($bm)->find($id);
    my $bt= Siva::Logic::Util->getBaseTemplateName($path);
    $c->stash->{template} = $bt.'/edit.tt2';
}

sub update :LocalRegex('^(\d+)\/update$') {
    my ($self, $c, $data) = @_;
    my $path = $c->req->path;
    my $id = $c->req->captures->[0];
    my %model_data = keys(%$data) ? %$data : ();
    my $bm = Siva::Logic::Util->getBaseModelName($path);
    $c->model('DBIC')->resultset($bm)->find($id)->update({%model_data});
    $c->res->body('redirect');
    $c->res->redirect('./show', 303);
}

sub delete :LocalRegex('^(\d+)\/delete$') {
    my ($self, $c) = @_;
    my $path = $c->req->path;
    my $id = $c->req->captures->[0];
    my $bm = Siva::Logic::Util->getBaseModelName($path);
    $c->stash->{model} = $c->model('DBIC')->resultset($bm)->find($id);
    my $bt= Siva::Logic::Util->getBaseTemplateName($path);
    $c->stash->{template} = $bt.'/show.tt2';
}

sub destroy :LocalRegex('^(\d+)\/destroy$') {
    my ($self, $c) = @_;
    my $path = $c->req->path;
    my $id = $c->req->captures->[0];
    my $bm = Siva::Logic::Util->getBaseModelName($path);
    $c->model('DBIC')->resultset($bm)->find($id)->delete;
    $c->res->body('redirect');
    $c->res->redirect('../list', 303);
}

1;
