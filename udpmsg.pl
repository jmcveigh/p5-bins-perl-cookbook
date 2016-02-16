#!/bin/perl -w
# udpmsg - send a message to the udpquotd server

use IO::Socket;
use strict;

my ($sock, $server_host, $msg, $port, $ipaddr, $hishost, $MAXLEN, $PORTNO, $TIMEOUT);
$MAXLEN = 1024;
$PORTNO = 5151;
$TIMEOUT = 5;

$server_host = shift;
$msg = "@ARGV";
$sock = IO::Socket::INET->new(Proto => 'udp', PeerPort => $PORTNO, PeerAddr => $server_host) or die "Creating socket: $!\n";
$sock->send($msg) or die "send: $!";
eval {
    local $SIG{ALRM} = sub {
        die "alarm time out";
    };
    
    alarm $TIMEOUT;
    
    $sock->recv($msg, $MAXLEN) or die "recv: $!";
    
    alarm 0;
    
    1;
} or die "recv from $server_host timeout after $TIMEOUT seconds.\n";
($port, $ipaddr) = sockaddr_in($sock->peername);
$hishost = gethostbyaddr($ipaddr, AF_INET);
print "Server $hishost responded ''$msg''\n";