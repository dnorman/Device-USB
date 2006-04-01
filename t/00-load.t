#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Device::USB' );
}

diag( "Testing Device::USB $Device::USB::VERSION, Perl $], $^X" );
