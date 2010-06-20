package Siva::Controller::TestSuite;

use strict;
use warnings;

use base 'Siva::Controller::Base';

use Data::Dumper;
use XML::LibXML;
use File::Path qw(make_path remove_tree);
use File::Temp qw(tempdir);
use IO::File;
use Archive::Zip;
use Encode;

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

sub list :Local {
    my ($self, $c) = @_;
    my %data = ();
#$c->log->debug("param1=".$c->request->parameters->{tags});
#    $data{name} = '%'.$c->request->parameters->{name}.'%' if $c->request->parameters->{name};
#    $data{tags} = '%'.$c->request->parameters->{tags}.'%' if $c->request->parameters->{tags};
#    $data{explanation} = '%'.$c->request->parameters->{explanation}.'%' if $c->request->parameters->{explanation};
    $data{name} = { -like => '%'.$c->request->parameters->{name}.'%'} if $c->request->parameters->{name};
    $data{tags} = { -like => '%'.$c->request->parameters->{tags}.'%'} if $c->request->parameters->{tags};
    $data{explanation} = { -like => '%'.$c->request->parameters->{explanation}.'%'} if $c->request->parameters->{explanation};
    $c->stash->{param} = $c->request->parameters;
    $self->SUPER::list( $c, \%data);
}

sub create :Local {
    my ($self, $c) = @_;
    my %data = (
      name        => $c->request->parameters->{name},
      filename    => $c->request->parameters->{filename},
      tags        => $c->request->parameters->{tags},
      explanation => $c->request->parameters->{explanation},
    );
    $self->SUPER::create( $c, \%data);
}

sub update :LocalRegex('^(\d+)\/update$') {
    my ($self, $c) = @_;
    my %data = (
      name        => $c->request->parameters->{name},
      filename    => $c->request->parameters->{filename},
      tags        => $c->request->parameters->{tags},
      explanation => $c->request->parameters->{explanation},
    );
    $self->SUPER::update( $c, \%data);
}

sub importdata :Local {
    my ($self, $c) = @_;
    my $path = $c->req->path;

    my $upload;
    unless ($upload = $c->req->upload('filename') ) {
      $c->detach('create');
    }
    my $parser = XML::LibXML->new();
    $parser->recover_silently(1);
    my $doc = $parser->parse_html_file($upload->tempname);

    my $bm = Siva::Logic::Util->getBaseModelName($path);
    my %data = (
      name => $c->request->parameters->{name},
      filename => $upload->filename,
      tags => $c->request->parameters->{tags},
      explanation => $c->request->parameters->{explanation},
    );
    my $model = $c->model('DBIC')->resultset($bm)->create({%data});
    my $model_id = $model->id;

    # get node to array
    my $xpath = '//table[@id="suiteTable"]/tbody/tr/td';
    my @nodes = $doc->findnodes( $xpath );
    my $i = 0;
    foreach my $node (@nodes) {
      my @a_node = $node->findnodes('a');
      if(@a_node) {
        $i++;
        my %data_child = (
          name        => $node->findvalue('a'),
          filename    => $a_node[0]->findvalue('@href'),
          tags        => '',
          explanation => '',
        );
        my $bcm = Siva::Logic::Util->getBaseChildModelName($path);
        my $model_child = $c->model('DBIC')->resultset($bcm)->create({%data_child});
        my $child_id = $model_child->id;

        my %data_map = (
          test_suite_id   => $model_id,
          test_case_id    => $child_id,
          map_order       => $i,
        );
        my $bmm = Siva::Logic::Util->getBaseMapModelName($path);
        $c->model('DBIC')->resultset($bmm)->create({%data_map});
      }
    }
    $c->res->body('redirect');
    $c->res->redirect('./'.$model_id, 303);
}

sub export :LocalRegex('^(\d+)\/export$') {
    my ($self, $c) = @_;
    my $id = $c->req->snippets->[0];
    my $path = $c->req->path;

    # make directory for testcase
    my $tmpdir = tempdir( CLEANUP => 1 );
    $c->log->debug("tempdirname=".$tmpdir);
    my $parentdir = $tmpdir.'/suite';
    make_path ($parentdir, {error => \my $err});
    if (@$err) {
      for my $diag (@$err) {
        my ($file, $message) = %$diag;
        if ($file eq '') {
          $c->log->debug("general error: $message");
        } else {
          $c->log->debug("problem unlinking $file: $message");
        }
      }
    } else {
      $c->log->debug("No error encountered");
    }
    my $bm = Siva::Logic::Util->getBaseModelName($path);
    my $model = $c->model('DBIC')->resultset($bm)->find($id);

    # create testsuite file
    my $parentfilename = $model->filename || "suite.html";
    my $parentfile = $parentdir."/".$parentfilename;
    my $parentname = $model->name || "no name";
   
    # make testsuite string;
    my $dom = XML::LibXML::Document->new('1.0', 'UTF-8');
    $dom->createInternalSubset("html", "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd");
    my $html = $dom->createElement('html');
    $html->setAttribute("xmlns", "http://www.w3.org/1999/xhtml");
    $html->setAttribute("xml:lang", "en");
    $html->setAttribute("lang", "en");
    my $head = $dom->createElement('head');
    my $meta = $dom->createElement('meta');
    $meta->setAttribute("http-equiv", "Content-Type");
    $meta->setAttribute("content", "text/html; charset=UTF-8");
    my $title = $dom->createElement('title');
    $title->appendText($parentname);
    $head->appendChild($meta);
    $head->appendChild($title);

    my $body = $dom->createElement('body');
    my $table = $dom->createElement('table');
    $table->setAttribute("id", "suiteTable");
    $table->setAttribute("cellpadding", "1");
    $table->setAttribute("cellspacing", "1");
    $table->setAttribute("border", "1");
    $table->setAttribute("class", "selenium");

    my $tbody = $dom->createElement('tbody');
    my $tr = $dom->createElement('tr');
    my $td = $dom->createElement('td');
    my $b = $dom->createElement('b');
    $b->appendText("Test Suite");
    $td->appendChild($b);
    $tr->appendChild($td);
    $tbody->appendChild($tr);

    # add test command.
    my $bmm = Siva::Logic::Util->getBaseMapModelName($path);
    my @model_map = $c->model('DBIC')->resultset($bmm)->search({
      test_suite_id => $id
      },{
      order_by => [ 'map_order' ]
    });

    foreach my $data ( @model_map ) {
#    foreach my $data ( $model->suite_case_maps ) {
      my $tr_b = $dom->createElement('tr');
      my $td_b1 = $dom->createElement('td');
      my $a = $dom->createElement('a');
      $a->setAttribute("href", $data->test_case_id->filename);
      $a->appendText($data->test_case_id->name);
      $td_b1->appendChild($a);
      $tr_b->appendChild($td_b1);
      $tbody->appendChild($tr_b);
    }

    $table->appendChild($tbody);
    $body->appendChild($table);

    $html->appendChild($head);
    $html->appendChild($body);
    $dom->setDocumentElement($html);
    my $text = $dom->toString();
    $c->log->debug("text=".$text);

    my $fh = new IO::File;
    if($fh->open("> $parentfile")) {
      $fh->binmode();
      print $fh $text;
      $fh->close;
    }

    # create zip
    my $zip = Archive::Zip->new();
    $zip->addTree( $tmpdir );
    my $zipfile = $tmpdir.'/temp.zip';
    $zip->writeToFileNamed($zipfile);

    $c->res->content_type('application/octet-stream');
    my $filename = 'Download suite.zip';
    $c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);

    my $fh2 = new IO::File;
    if($fh2->open("< $zipfile")) {
      $fh2->binmode();
      my @list = <$fh2>;
      my $body_text = join('', @list);
      $c->res->body($body_text);
      $fh2->close;
    }

    #delete temp dir
    if( -d $tmpdir ) {
      remove_tree( $tmpdir );
    }
}

sub select :LocalRegex('^(\d+)\/select$') {
    my ($self, $c) = @_;
#$c->log->debug("param1=".$c->req->param('name'));
#$c->log->debug("param1=".$c->request->parameters->{name});

#    my @data = [
#      {name => $c->request->parameters->{name}},
#      {tags => $c->request->parameters->{tags}},
#    ];
#    $self->SUPER::select( $c, \@data);
    my %data = ();
    $data{name} = '%'.$c->request->parameters->{name}.'%' if $c->request->parameters->{name};
    $data{tags} = '%'.$c->request->parameters->{tags}.'%' if $c->request->parameters->{tags};
    $data{explanation} = '%'.$c->request->parameters->{explanation}.'%' if $c->request->parameters->{explanation};
    $c->stash->{param} = $c->request->parameters;
    $self->SUPER::select( $c, \%data);
}

sub selectdata :LocalRegex('^(\d+)\/selectdata$') {
    my ($self, $c) = @_;
    my $id = $c->req->snippets->[0];
    my $path = $c->req->path;
    my $bmm = Siva::Logic::Util->getBaseMapModelName($path);
    my %cnd = ();
    $cnd{test_suite_id} = $id;
    my $map_model = $c->model('DBIC')->resultset($bmm)->search({%cnd})->delete_all;
#$c->log->debug("cases=".$c->request->parameters->{cases});
#    my $cases = $c->request->parameters->{cases};
    my $cases = $c->request->parameters->{casesms2side__dx};
#$c->log->debug("ref=".ref($cases));
#$c->log->debug("cases=".Dumper($cases));
    if(ref($cases) eq "ARRAY") {
      my @ar_cases = @$cases;
      my $i = 0;
      foreach my $case (@ar_cases) {
        $i++;
#$c->log->debug("case=".$case);
        my %map_data_new = (
          test_suite_id => $id,
          test_case_id => $case,
          map_order => $i,
        );
        my $map_model_new = $c->model('DBIC')->resultset($bmm)->create({%map_data_new});

      }
    } elsif(length($cases)) {
#$c->log->debug("case=".$cases);
      my %map_data_new = (
        test_suite_id => $id,
        test_case_id => $cases,
        map_order => '1',
      );
      my $map_model_new = $c->model('DBIC')->resultset($bmm)->create({%map_data_new});
    }

    $c->res->body('redirect');
    $c->res->redirect('./show', 303);

}

1;
