use strict;
use warnings;

use Test::More tests => 3;
use_ok( 'Catalyst::Test', 'Siva' );
use_ok('Siva::Controller::TestCase');

ok( request('testcase')->is_success, 'Request should succeed' );

