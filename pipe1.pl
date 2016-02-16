#!/bin/perl -w
# pipe1 - use pipe and fork so parent can send to child

use IO::Handle;

my ($reader, $writer);
pipe $reader, $writer;
$writer->autoflush(1);

if ($pid = fork) {
    close $reader;
    print $writer "Parent Pid $$ is sending this\n";
    close $writer;
    waitpid($pid, 0);
} else {
    die "cannot fork: $!" unless defined $pid;
    close $writer;
    chomp($line = <$reader>);
    print "Child Pid $$ just read this: '$line'\n";
    close $reader;
    exit;
}
