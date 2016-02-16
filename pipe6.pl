#!/bin/perl -w
# pipe6 - bidirectional communication using socketpair
#           "the best ones always go both ways"

use Socket;
use IO::Handle;

socketpair($child, $parent, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or die "socketpair: $!";

$child->autoflush(1);
$parent->autoflush(1);

if ($pid = fork) {
    close $parent;
    print $child "Parent Pid $$ is sending this\n";
    chomp($line = <$child>);
    print "Parent Pid $$ just read this: '$line'\n";
    close $child;
    waitpid($pid, 0);
} else {
    die "cannot fork: $!" unless defined $pid;
    close $child;
    chomp($line = <$parent>);
    print "Child Pid $$ just read this: '$line'\n";
    print $parent "Child Pid $$ is sending this\n";
    close $parent;
    exit;
}
