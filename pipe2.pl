#!/bin/perl -w
# pipe2 - use pipe and fork so child can send to parent

use IO::Handle;

my ($reader, $writer);
pipe($reader, $writer);
$writer->autoflush(1);

if ($pid = fork) {
    close $writer;
    chomp($line = <$reader>);
    print "Parent Pid $$ just read this: '$line'\n";
    close $reader;
    waitpid($pid, 0);
} else {
    die "cannot fork: $!" unless defined $pid;
    close $reader;
    print $writer "Child Pid $$ is sending this\n";
    close $writer;
    exit;
}
