package Siva::Logic::Util;

# hashmap
my %pathmap = (
  'testcase'    => 'TestCase',
  'testcommand' => 'TestCommand',
  'testsuite'   => 'TestSuite',
  'suitecasemap'=> 'SuiteCaseMap',
  'casecommandmap' => 'CaseCommandMap',
);

my %childmap = (
  'testcase'    => 'TestCommand',
  'testsuite'   => 'TestCase',
);

my %mapmap = (
  'testcase'    => 'CaseCommandMap',
  'testsuite'   => 'SuiteCaseMap',
);

sub getBaseModelName {
    my ($self, $path) = @_;
    $path=~ /^(\w+)/;
    my $name = $pathmap{$1};
    return $name;
}

sub getBaseChildModelName {
    my ($self, $path) = @_;
    $path=~ /^(\w+)/;
    my $name = $childmap{$1};
    return $name;
}

sub getBaseMapModelName {
    my ($self, $path) = @_;
    $path=~ /^(\w+)/;
    my $name = $mapmap{$1};
    return $name;
}

sub getBaseTemplateName {
    my ($self, $path) = @_;
    $path=~ /^(\w+)/;
    my $name = lc( $pathmap{$1} );
    return $name;
}

1;

