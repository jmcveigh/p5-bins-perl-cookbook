#!/bin/perl -w
# vbsh - very bad shell
use strict;

use Term::ReadLine;
use POSIX qw(:sys_wait_h);

my $term = Term::ReadLine->new("Simple Shell");
my $OUT = $term->OUT() || *STDOUT;
my $cmd;

while (defined ($cmd = $term->readline('$ '))) {
    my @output = `$cmd`;
    my $exit_value = $? >> 8;
    my $signal_num = $? & 127;
    my $dumped_core = $? & 128;
    
    printf $OUT "Program terminated with status %d from signal %d%s\n", $exit_value, $signal_num, $dumped_core ? " (core dumped)" : "";
    
    print @output;
    $term->addhistory($cmd);
}
