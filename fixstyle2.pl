#!/bin/perl -w
# fixstyle2 - like fixstyle but faster for many many changes

use strict;

my $verbose = (@ARGV && $ARGV[0] eq '-v' && shift);
my %change = ();

while (<DATA>) {
    chomp;
    my ($in, $out) = split /\s*=>\s*/;
    next unless $in && $out;
    $change{$in} = $out;
}

if (@ARGV) {
    $^I = ".orig";
} else {
    warn "$0: Reading from stdin\n" if -t STDIN;
}

while (<>) {
    my $i = 0;
    s/^(\s+)// && print $1; # emit leading whitespace
    for (split /(\s+)/, $_, -1) { # preserve trailing whitespace
        print( ($i++ & 1) ? $_ : ($change{$_} || $_));
    }
}
__END__
analysed        => analyzed
built-in        => builtin
chastized       => chastised
commandline     => command-line
de-allocate     => deallocate
dropin          => drop-in
hardcode        => hard-code
meta-data       => metadata
multicharacter  => multi-character
multiway        => multi-way
non-empty       => nonempty
non-profit      => nonprofit
non-trappable   => nontrappable
pre-define      => predefine
preextend       => pre-extend
re-compiling    => recompiling
reenter         => re-enter
turnkey         => turn-key
