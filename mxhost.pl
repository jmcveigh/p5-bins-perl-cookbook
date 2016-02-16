#!/bin/perl -w
# mxhost - find mx exchangers for a host
use Net::DNS;
use strict;

my ($host, $res, @mx);

$host = shift or die "usage: $0 hostname\n";
$res = Net::DNS::Resolver->new();
@mx = mx($res, $host) or die "Can't find MX records for $host (" . $res->errorstring . ")\n";

foreach my $record (@mx) {
    print $record->preference, " ", $record->exchange, "\n";
}