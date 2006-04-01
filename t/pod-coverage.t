#!perl -T

use Test::More;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;
all_pod_coverage_ok(
    {   also_private => [
            qr/^libusb_\w+$/,
	    qr/^dl_load_flags$/,
            qr/^lib_find_usb_device$/,
            qr/^lib_get_usb_busses$/,
            qr/^lib_list_busses$/,
	]
    }
);
