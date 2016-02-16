#!/bin/perl
# tailwtmp - watch for logins and logouts;
# uses linux utmp structure, from utmp(S)
$typedef = "s x2 i A12 A4 l A8 A16 l";
$sizeof = length pack($typedef, () );
use IO::File;
open(WTMP, "< :raw", "/var/log/wtmp") or die "can't open /var/log/wtmp: $!";
seek(WTMP, 0, SEEK_END);
for (;;) {
    while (read(WTMP, $buffer, $sizeof) == $sizeof) {
        ($type, $pid, $line, $id, $time, $user, $host, $addr) = unpack($typedef, $buffer);
        next unless $user && ord($user) && $time;
        printf "%1d %-8s %-12s %2s %-24s %-16s %5d %08x\n",$type, $user, $line, $id, scalar(localtime($time)), $host, $pid, $addr;
    }
    for ($size = -s WTMP; $size == -s WTMP; sleep 1) {}
    WTMP->clearer();
}
