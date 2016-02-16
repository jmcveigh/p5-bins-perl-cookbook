#!/bin/perl -w
# pipe5 - bidirectional communication using two pipe pairs
#           designed for the sockpair-challenged

use IO::Handle;

my ($parent_rdr, $child_wtr, $child_rdr, $parent_wtr);
pipe $parent_rdr, $child_wtr;
pipe $child_rdr, $parent_wtr;

$child_wtr->autoflush(1);
$parent_wtr->autoflush(1);

if ($pid = fork) {
    close $parent_rdr;
    close $parent_wtr;
    print $child_wtr "Parent Pid $$ is sending this\n";
    chomp($line = <$child_rdr>);
    print "Parent Pid $$ just read this: '$line'\n";
    close $child_rdr;
    close $child_wtr;
    waitpid($pid, 0);
} else {
    die "cannot fork: $!" unless defined $pid;
    close $child_rdr;
    close $child_wtr;
    chomp($line = <$parent_rdr>);
    print "Parent Pid $$ just read this: '$line'\n";
    print $parent_wtr "Child Pid $$ is sending this\n";
    close $child_rdr;
    close $parent_wtr;
    exit;
}
