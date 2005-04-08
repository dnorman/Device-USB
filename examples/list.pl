#!/usr/bin/perl
#
use Device::USB;
use Data::Dumper;

my $devs = List();

print Data::Dumper->Dump([$devs]);
