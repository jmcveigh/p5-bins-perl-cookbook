#!/bin/perl
# popgrep2 - grep for abbreviations of places that say "pop"
# version 2: fast way using qr//
@popstates = qw(CO ON MI WI MN);
@poppats = map { qr/\b$_\b/ } @popstates;
LINE: while (defined($line = <>)) {
    for $pat (@poppats) {
        if ($line =~/$pat/) {
            print;
            next LINE;
        }
    }
}