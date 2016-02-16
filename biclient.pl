#!/bin/perl -w
# biclient - bidirection forking client

use strict;
use IO::Socket;

my ($host, $port, $kidpid, $handle, $line);

unless (@ARGV == 2) {
    die "usage: $0 host port";
}

($host, $port) = @ARGV;

$handle = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $host, PeerPort => $port) or die "can't connect to port $port on $host: $!";

$handle->autoflush(1);
print STDERR "[Connected to $host:$port]\n";

die "can't fork: $!" unless defined($kidpid = fork());

if ($kidpid) {
    while (defined ($line = <$handle>)) {
        print STDOUT $line;
    }
    
    kill("TERM" => $kidpid);
} else {
    while (defined ($line = <STDIN>)) {
        print $handle $line;
    }
}

exit;