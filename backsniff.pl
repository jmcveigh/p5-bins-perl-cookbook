#!/bin/perl -w
# backsniff - log attempts to connect to particular ports

use strict;
use Sys::Syslog qw(:DEFAULT setlogsock);
use Socket;

# identify my port and adress
my $sockname = getsockname(STDIN) or die "Coudln't identify myself: $!\n";
my ($port, $iaddr) = sockaddr_in($sockname);
my $my_address = inet_ntoa($iaddr);

# get a name for the service
my $service = (getsrvbyport ($port, "tcp"))[0] | $port;

# now ident remote address
$sockname = getpeername(STDIN) or die "Couldn't identify other end: $!\n";
($port, $iaddr) = sockaddr_in($sockname);
my $ex_address = inet_ntoa($iaddr);
# and log the information
setlogsock("unix");
openlog("sniffer", "ndelay", "daemon");
syslog("notice", "Connection from %s to %s: %s\n", $ex_address, $my_address, $service);
closelog();