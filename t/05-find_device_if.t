#!perl -T

use Test::More tests => 11;
use Device::USB;

my $usb = Device::USB->new();

ok( defined $usb, "Object successfully created" );
can_ok( $usb, "find_device_if" );

ok( !defined $usb->find_device_if(
            sub { 0xFFFF == $_->idVendor() && 0xFFFF == $_->idProduct() }
        ),
    "No device found"
);

eval { $usb->find_device_if() };
like( $@, qr/Missing predicate/, "Requires a predicate." );

eval { $usb->find_device_if( 1 ) };
like( $@, qr/Predicate must be/, "Requires a code reference." );

my $busses = $usb->list_busses();
ok( defined $busses, "USB busses found" );

my $found_device = find_an_installed_device( 0, @{$busses} );

SKIP:
{
    skip "No USB devices installed", 5 unless defined $found_device;

    my $vendor = $found_device->idVendor();
    my $product = $found_device->idProduct();

    my $dev = $usb->find_device_if(
        sub { $vendor == $_->idVendor() && $product == $_->idProduct() }
    );

    ok( defined $dev, "Device found." );
    is_deeply( $dev, $found_device, "first device matches" );

    my $count = @{$busses};
    skip "Only one USB device installed", 3 if $count < 2;

    $found_device = undef;
    for(my $i = 1; $i < $count; ++$i)
    {
        my $dev = find_an_installed_device( $i, @{$busses} );
        # New vendor/product combination
        if($vendor != $dev->idVendor() || $product != $dev->idProduct())
        {
            $found_device = $dev;
            last;
        }
    }
    $vendor = $found_device->idVendor();
    $product = $found_device->idProduct();

    $dev = $usb->find_device_if(
        sub { $vendor == $_->idVendor() && $product == $_->idProduct() }
    );

    ok( defined $dev, "Device found." );
    is_deeply( $dev, $found_device, "second device matches" );

    my $hub = $usb->find_device_if( sub { 9 == $_->bDeviceClass() } );
    ok( $hub && 9 == $hub->bDeviceClass(), "Hub found." );
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
