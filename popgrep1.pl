#!/bin/perl
@popstates = qw(CO ON MI WI MN);
LINE: while (defined($line = <>)) {
    for $state (@popstates) {
        if ($line =~ /\b$state\b/) {
            print;
            next LINE;
        }
    }
}