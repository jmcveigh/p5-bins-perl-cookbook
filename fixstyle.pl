#!/bin/perl -w
# fixstyle - switch first set of <DATA> strings to second set
#  usage: $0 [-v] [files ...]

use strict;

my $verbose = (@ARGV && $ARGV[0] eq '-v' && shift);
if (@ARGV) {
    $^I = ".orig"; # preserve old files    
} else {
    warn "$0: Reading from stdin\n" if -t STDIN;
}

my $code = "while (<>) {\n";
# read in config, build up code to eval
while (<DATA>) {
    chomp;
    my ($in, $out) = split /\s*=>\s*/;
    next unless $in && $out;
    $code .= "s{\\Q$in\\E}{$out}g";
    $code .= "&& printf STDERR qq($in => $out at \$ARGV line \$.\\n)" if $verbose;
    $code .= ";\n";
}

$code .= "print; \n}\n";
eval "{ $code } 1" || die;
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
