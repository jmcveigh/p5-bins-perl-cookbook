#!/bin/perl
# sharetest - test shared variables across forks

use IPC::Sharable;

$handle = tie $buffer, 'IPC::Sharable', undef, { destroy => 1 };
$SIG{INT} = sub { die "$$ dying\n" };

for (1 .. 10) {
    unless ($child = fork) {
        die "cannot fork: $!" unless defined $child;
        squabble();
        exit;
    }
    
    push @kids, $child;
}

while (1) {
    print "Buffer is $buffer\n";
    sleep 1;
}

die "Not reached";

sub squabble {
    my $i = 0;
    while (1) {
        next if $buffer =~ /^$$\b/o;
        $handle->shlock();
        $i++;
        $buffer = "$$ $i";
        $handle->shunlock();
    }    
}
