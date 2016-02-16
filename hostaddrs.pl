#!/bin/perl -w
# hostaddrs - canonize name and show addresses

use Socket;
use Net::hostent;
use strict;

my ($name, $hent, @addresses);
$name = shift || die "usage: $0 hostname\n";
if ($hent = gethostbyname($name)) {
    $name = $hent->name;
    my $addr_ref = $hent->addr_list;
    @addresses = map { inet_ntoa($_) } @$addr_ref;    
}

print "$name => @addresses\n";
