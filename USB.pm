package Device::USB;

use 5.006;
use strict;
use warnings;
use Errno;
use Carp;

require Exporter;
require DynaLoader;
use AutoLoader;

our $VERSION = '0.01';

our @ISA = qw(Exporter DynaLoader);

# This allows declaration use Device::USB ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	List
);

sub AUTOLOAD {
	# This AUTOLOAD is used to 'autoload' constants from the constant()
	# XS function.  If a constant is not found then control is passed
	# to the AUTOLOAD in AutoLoader.

	my $constname;
	our $AUTOLOAD;
	($constname = $AUTOLOAD) =~ s/Device::USB//;
	croak "&$_[0] not defined in Device::USB" if $constname eq 'constant';
	my $val = constant($constname, @_ ? $_[0] : 0);
	if ($! != 0) {
		if ($!{EINVAL}) {
		    $AutoLoader::AUTOLOAD = $AUTOLOAD;
		    goto &AutoLoader::AUTOLOAD;
		} else {
		    croak "Your vendor has not defined Device::USB macro $constname";
		}
	}
	{
		no strict 'refs';
		# Fixed between 5.005_53 and 5.005_61
		if ($] >= 5.00561) {
		    *$AUTOLOAD = sub () { $val };
		} else {
		    *$AUTOLOAD = sub { $val };
		}
	}
	goto &$AUTOLOAD;
}

Device::USB->bootstrap($VERSION);

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

# documentation to come later
1;
__END__

=head1 NAME

Device::USB - perl api to libusb

=head1 SYNOPSIS

  use Device::USB;

  my $list = List();

  # dump $list with Data::Dumper for details

=head1 DESCRIPTION

This module will allow custom usb drivers to be written in perl.
Currently it only lists the devices.

=head1 NOTES

Expect the interface to change.  You must have libusb v0.1.8 installed first.

=head1 TODO

Documentation ;)

=head1 AUTHOR

David Davis, E<lt>xantus@cpan.orgE<gt>

=head1 SEE ALSO

perl(1), L<http://libusb.sf.net/>

=cut
