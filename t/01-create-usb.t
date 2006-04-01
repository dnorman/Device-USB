#!perl -T

use Test::More tests => 2;

use Device::USB;

my $usb = Device::USB->new();

ok( defined $usb, "Object successfully created" );
isa_ok( $usb, 'Device::USB' );
