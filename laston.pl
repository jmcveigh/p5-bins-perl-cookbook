#!/bin/perl
# laston - find out when given user last logged on
use User::pwent;
use IO::Seekable qw(SEEK_SET);

open(LASTLOG, "< :raw", "/var/log/lastlog") or die "can't open /var/log/lastlog: #!";
     
$typedef = "L A12 A16"; # linux fmt; sunos is "L A8 A16"
$sizeof = length(pack($typedef, ()));

for $user (@ARGV) {
    $U = ($user =~ /^\d+$/) ? getpwuid($user) : getpwnam($user);
    unless ($U) { warn "no such uid $user\n"; next; }
    seek(LASTLOG, $U->uid * $sizeof, SEEK_SET) or die "seek failed: $!";
    read(LASTLOG, $buffer, $sizeof) == $sizeof or next;
    ($time, $line, $host) = unpack($typedef, $buffer);
    printf "%-8s UID %5d %s%s%s\n", $U->name, $U->uid, $time ? ("at " . localtime($time)) : "never logged in", $line && " on $line", $host && " from $host";
}