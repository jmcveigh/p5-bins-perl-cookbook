#!/bin/perl -w
# pipe3 - use forking open so parent can send to child

use IO::Handle;

if ($pid = open($child, "|-")) {
    $child->autoflush(1);
    print $child "Parent Pid $$ is sending this\n";
    close $child;
} else {
    die "cannot fork: $!" unless defined $pid;
    chomp($line = <STDIN>);
    print "Child Pid $$ just read this: '$line'\n";
    exit;
}
