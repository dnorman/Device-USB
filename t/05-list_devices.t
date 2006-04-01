#!perl -T

use Test::More tests => 7;
use Device::USB;
use Data::Dumper;

my $usb = Device::USB->new();

ok( defined $usb, "Object successfully created" );
can_ok( $usb, "list_devices" );

my $busses = $usb->list_busses();
ok( defined $busses, "USB busses found" );

my $found_device = find_an_installed_device( 0, @{$busses} );

SKIP:
{
    skip "No installed USB devices", 4 unless defined $found_device;

    my $vendor = $found_device->idVendor();
    my $product = $found_device->idProduct();

    my @devices = $usb->list_devices( $vendor, $product );
    my $device_count = @devices;

    ok( 0 < $device_count, "At least one device found" );
    my $matches = grep { $_->idVendor() == $vendor && $_->idProduct() == $product }
         @devices;
    is( $matches, $device_count, "All match the criteria" );
    
    my @vendor_devices = $usb->list_devices( $vendor, $product );
    my $vdevice_count = @vendor_devices;

    ok( $device_count <= $vdevice_count, "At least one device found" );
    $matches = grep { $_->idVendor() == $vendor } @devices;
    is( $matches, $vdevice_count, "All match the criteria" );
}


sub find_an_installed_device
{
    my $which = shift;
    foreach my $bus (@_)
    {
        next unless @{$bus->devices()};
	return $bus->devices()->[0] unless $which--;
    }

    return;
}
