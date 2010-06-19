package Siva::Controller::TestCase;

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

use constant CASE1_BASE => 10000;
use constant CASE2_BASE => 20000;
use constant CMND1_BASE => 30000;

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
    my $xpath = "//tbody/tr";
    my @nodes = $doc->findnodes( $xpath );
    my $i = 0;
    foreach my $node (@nodes) {
      $i++;
      my %data_child = (
        command      => $node->findvalue( "td[1]" ),
        target       => $node->findvalue( "td[2]" ),
        value        => $node->findvalue( "td[3]" ),
      );
      my $bcm = Siva::Logic::Util->getBaseChildModelName($path);
      my $model_child = $c->model('DBIC')->resultset($bcm)->create({%data_child});
      my $model_child_id = $model_child->id;
      my %data_map = (
        test_case_id    => $model_id,
        test_command_id => $model_child_id,
        map_order       => $i,
      );
      my $bmm = Siva::Logic::Util->getBaseMapModelName($path);
      my $model_map = $c->model('DBIC')->resultset($bmm)->create({%data_map});
      my $model_map_id = $model_map->id;
    }
    $c->res->body('redirect');
    $c->res->redirect('./'.$model_id, 303);
}

sub importdataone :LocalRegex('^(\d+)\/importdata$') {
    my ($self, $c) = @_;
    my $path = $c->req->path;
    my $id = $c->req->snippets->[0];
    my $upload;
    unless ($upload = $c->req->upload('filename') ) {
      $c->detach('index');
    }

    my $parser = XML::LibXML->new();
    $parser->recover_silently(1);
    my $doc = $parser->parse_html_file($upload->tempname);

    my $model_id = $id;
    # get node to array
    my $xpath = "//tbody/tr";
    my @nodes = $doc->findnodes( $xpath );
    my $i = 0;
    foreach my $node (@nodes) {
      $i++;
      my %data_child = (
        command      => $node->findvalue( "td[1]" ),
        target       => $node->findvalue( "td[2]" ),
        value        => $node->findvalue( "td[3]" ),
      );
      
      my $bcm = Siva::Logic::Util->getBaseChildModelName($path);
      my $model_child = $c->model('DBIC')->resultset($bcm)->create({%data_child});
      my $model_child_id = $model_child->id;
      my %data_map = (
        test_case_id    => $model_id,
        test_command_id => $model_child_id,
        map_order       => $i,
      );
      my $bmm = Siva::Logic::Util->getBaseMapModelName($path);
      my $model_map = $c->model('DBIC')->resultset($bmm)->create({%data_map});
      my $model_map_id = $model_map->id;
    }
    $c->res->body('redirect');
#    $c->res->redirect('./'.$model_id, 303);
    $c->res->redirect('./show', 303);

}

sub export :LocalRegex('^(\d+)\/export$') {
    my ($self, $c) = @_;
    my $id = $c->req->snippets->[0];
    my $path = $c->req->path;
    # make directory for testcase
    my $tmpdir = tempdir( CLEANUP => 1 );
    $c->log->debug("tempdirname=".$tmpdir);
    my $casedir = $tmpdir.'/case';
    make_path ($casedir, {error => \my $err});
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

    # create testcase file
    my $casefilename = $model->filename || "case.html";
    my $casefile = $casedir."/".$casefilename;
    my $casename = $model->name || "no name";

    # make testcase string;
    my $dom = XML::LibXML::Document->new('1.0', 'UTF-8');
    $dom->createInternalSubset("html", "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd");
    my $html = $dom->createElement('html');
    $html->setAttribute("xmlns", "http://www.w3.org/1999/xhtml");
    $html->setAttribute("xml:lang", "en");
    $html->setAttribute("lang", "en");
    my $head = $dom->createElement('head');
    $head->setAttribute("profile", "http://selenium-ide.openqa.org/profiles/test-case");
    my $meta = $dom->createElement('meta');
    $meta->setAttribute("http-equiv", "Content-Type");
    $meta->setAttribute("content", "text/html; charset=UTF-8");
    my $title = $dom->createElement('title');
    $title->appendText($casename);
    $head->appendChild($meta);
    $head->appendChild($title);
    my $body = $dom->createElement('body');
    my $table = $dom->createElement('table');
    $table->setAttribute("cellpadding", "1");
    $table->setAttribute("cellspacing", "1");
    $table->setAttribute("border", "1");
    my $thead = $dom->createElement('thead');
    my $tr = $dom->createElement('tr');
    my $td = $dom->createElement('td');
    $td->setAttribute("rowspan", "1");
    $td->setAttribute("colspan", "3");
    $td->appendText($casename);
    $tr->appendChild($td);
    $thead->appendChild($tr);
    my $tbody = $dom->createElement('tbody');

    # add test command.
    my $bmm = Siva::Logic::Util->getBaseMapModelName($path);
    my @model_map = $c->model('DBIC')->resultset($bmm)->search({
      test_case_id => $id
      },{
      order_by => [ 'map_order' ]
    });
    foreach my $data ( @model_map ) {
      my $tr_b = $dom->createElement('tr');
      my $td_b1 = $dom->createElement('td');
      my $td_b2 = $dom->createElement('td');
      my $td_b3 = $dom->createElement('td');
      $td_b1->appendText($data->test_command_id->command);
      $td_b2->appendText($data->test_command_id->target);
      $td_b3->appendText($data->test_command_id->value);
      $tr_b->appendChild($td_b1);
      $tr_b->appendChild($td_b2);
      $tr_b->appendChild($td_b3);
      $tbody->appendChild($tr_b);
    }
    $table->appendChild($thead);
    $table->appendChild($tbody);
    $body->appendChild($table);
    $html->appendChild($head);
    $html->appendChild($body);
    $dom->setDocumentElement($html);
    my $text = $dom->toString();
    $c->log->debug("text=".$text);
    my $fh = new IO::File;
    if($fh->open("> $casefile")) {
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
    my $filename = 'Important ABC.zip';
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

sub convert :LocalRegex('^(\d+)\/convert$') {
    my ($self, $c) = @_;
    my $id = $c->req->snippets->[0];
    my $path = $c->req->path;
    # get TestCommand
    my $bm = Siva::Logic::Util->getBaseModelName($path);
    my $bcm = Siva::Logic::Util->getBaseChildModelName($path);
    my $bmm = Siva::Logic::Util->getBaseMapModelName($path);
    my $model = $c->model('DBIC')->resultset($bm)->find($id);
    my $casename = $model->name;
    my @order_bef = ();
    my %order_hash;
    # もし、入力コマンドがあったらTestCommand追加
    my $flg_bind = 0;
    my $cnt = 0;
    foreach my $data ( $model->case_command_maps ) {
      my $base_num;
      if ($data->test_command_id->command =~ /^(type|select|checked)$/) {
        # もしvalueが既に変数だったら処理しない
        if ($data->test_command_id->value !~ /^\$\{\w+\.\w+\}/) {
          my %child_data_new = (
            command => "setCaseValue",
            target  => $casename.'.'.$data->test_command_id->id,
            value   => $data->test_command_id->value
          );
          my $child_model_new = $c->model('DBIC')->resultset($bcm)->create({%child_data_new});
          my $child_model_new_id = $child_model_new->id;
          $cnt++;
          my $num_new = CASE1_BASE + $cnt;
          push(@order_bef, $num_new);
          # CaseCommandMap追加
          my %map_data_new = (
            test_case_id => $id,
            test_command_id => $child_model_new_id,
            map_order => $num_new
          );
          my $map_model_new = $c->model('DBIC')->resultset($bmm)->create({%map_data_new});
          my $map_model_new_id = $map_model_new->id;
          # テストコマンドのソート順を並び替え
          # testcase_idで絞り込んだcase_command_mapをmap_order順に取得
          # 仮オーダーのcommand_idハッシュ作成
          $order_hash{$num_new} = $child_model_new_id;

          # テストケースのvalueを変数に変換
          my %child_data_cur = (
            value   => '${'.$casename.'.'.$data->test_command_id->id.'}'
          );
          my $child_model_cur = $c->model('DBIC')->resultset($bcm)->find($data->test_command_id->id)->update({%child_data_cur});
        }
        $base_num = CMND1_BASE;
      } elsif ($data->test_command_id->command =~ /^(setCaseValue)$/) {
        $base_num = CASE1_BASE;
      } elsif ($data->test_command_id->command =~ /^(bindValue)$/) {
        $flg_bind = 1;
        $base_num = CASE2_BASE;
      } else {
        $base_num = CMND1_BASE;
      }
      # sort_orderと、command_idの配列作成
      # testcase_idで絞り込んだcase_command_mapをmap_order順に取得
      $cnt++;
      #数字は重複しないようにインクリメント（before は 10000 台、 bind は20000台、 その他は 30000台）
      # command のタイプから、仮のオーダーを設定する。
      my $num_cur = $base_num + $cnt;
      push(@order_bef, $num_cur);
      # 仮オーダーのcommand_idハッシュ作成
      $order_hash{$num_cur} = $data->test_command_id->id;
    }
    # もし、bindValueがなければTestCommand追加
    if( $flg_bind == 0) {
      my %child_data_new = (
        command => "bindValue",
        target  => $casename,
        value   => ""
      );
      my $child_model_new = $c->model('DBIC')->resultset($bcm)->create({%child_data_new});
      my $child_model_new_id = $child_model_new->id;
      $cnt++;
      my $num_new = CASE2_BASE + $cnt;
      push(@order_bef, $num_new);
      # CaseCommandMap追加
      my %map_data_new = (
        test_case_id => $id,
        test_command_id => $child_model_new_id,
        map_order => $num_new
      );
      my $map_model_new = $c->model('DBIC')->resultset($bmm)->create({%map_data_new});
      my $map_model_new_id = $map_model_new->id;
      # テストコマンドのソート順を並び替え
      # testcase_idで絞り込んだcase_command_mapをmap_order順に取得
      # 仮オーダーのcommand_idハッシュ作成
      $order_hash{$num_new} = $child_model_new_id;
    }

    # ソートする
    my @order_aft = sort {$a <=> $b} @order_bef;

    # 番号の振り直しを行う
    my %order_hash_aft;
    my $length = @order_aft;
    $c->log->debug("length=".$length);
    for( my $i = 0; $i < $length; $i++) {
      my $iii = $i+1;
      $c->log->debug("i+1=$iii;order_aft[i]=".$order_aft[$i].";" );
      $order_hash_aft{ $order_hash{ $order_aft[$i] } } = ($i + 1);
    }
    # case_command_map のソート順変更
    my $model_sort = $c->model('DBIC')->resultset($bm)->find($id);
    my $ii = 0;
    foreach my $data_sort ( $model_sort->case_command_maps ) {
      $c->log->debug("ii=$ii;command_id=".$data_sort->test_command_id->id.";value=".$data_sort->test_command_id->value );
      $c->log->debug("map_order=".$order_hash_aft{ $data_sort->test_command_id->id });
      # テストケースのvalueを変数に変換
      my %child_data_sort = (
        map_order   => $order_hash_aft{ $data_sort->test_command_id->id }
      );
      my $child_model_sort = $data_sort->update({%child_data_sort});
    }
    $c->res->body('redirect');
    $c->res->redirect('./show', 303);
}

1;
