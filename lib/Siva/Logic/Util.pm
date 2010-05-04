package Siva::Logic::Util;

# hashmap
my %pathmap = (
  'testcase' => 'TestCase',
);

sub getBaseModelName {
    my ($self, $path) = @_;
    $path=~ /^(\w+)/;
    my $name = $pathmap{$1};
    return $name;
}

sub getBaseTemplateName {
    my ($self, $path) = @_;
    $path=~ /^(\w+)/;
    my $name = lc( $pathmap{$1} );
    return $name;
}

sub getBasePathName {
    my ($self, $path) = @_;
    $path=~ /^(\w+)/;
    my $name = lc( $pathmap{$1} );
    return $name;
}

1;

