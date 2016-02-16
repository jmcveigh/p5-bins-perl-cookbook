#!/bin/perl -w
# pipe4 - use forking open so child can send to parent

use IO::Handle;

if ($pid = open $child, "-|") {
    chomp($line = <$child>);
    print "Parent Pid $$ just read this: '$line'\n";
    close $child;
} else {
    die "cannot fork: $!" unless defined $pid;
    STDOUT->autoflush(1);
    print STDOUT "Child Pid $$ is sending this\n";
    exit;
}
