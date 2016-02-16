#!/bin/perl
# bigfact - calculate prime factors
use strict;
use integer;
our ($opt_b, $opt_d);

use Getopt::Std;

@ARGV && getopts('bd') || die "usage: $0 [-b] number ...";

load_biglib() if $opt_b;

ARG: foreach my $orig (@ARGV) {
    my ($n, %factors, $factor);
    $n = $opt_b ? Math::BigInt->new($orig) : $orig;
    if ($n + 0 ne $n) { # don't use -w for this
        printf STDERR "bigfact: %s woudl become %s\n", $n, $n+0 if $opt_d;
        load_biglib();
        $n = Math::BigInt->new($orig);
    }
    printf "%-10s ", $n;
    
    # Here $sqi will be the square of $i.  We will take advantage
    # of the fact that ($i + 1) ** 2 == $i ** 2 + 2 * $i + 1
    for (my ($i, $sqi) = (2, 4); $sqi <= $n; $sqi += 2 * $i ++ + 1) {
        while ($n % $i == 0) {
            $n /= $i;
            print STDERR "<$i>" if $opt_d;
            $factors{$i}++;
        }
        
    }
    
    if ($n != 1 && $n != $orig) { $factors{$n}++ }
    if (! %factors) {
        print "PRIME\n";
        next ARG;
    }
    
    for my $factor ( sort { $a <=> $b } keys %factors ) {
        print "$factor";
        if ($factors{$factor} > 1) {
            print "**$factors{$factor}";
        }
        print " ";
        
    }
    print "\n";
}

# this simulates a use, but at runtime
sub load_biglib {
    require Math::BigInt;
    Math::BigInt->import(); # immaterial?
}