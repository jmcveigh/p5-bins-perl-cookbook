#!/bin/perl -w
# pmdesc - describe pm files
# tchrist@perl.com

use strict;
use File::Find qw(find);
use Getopt::Std qw(getopts);
use Carp;

use vars (
    q!$opt_v!,
    q!$opt_w!,
    q!$opt_a!,
    q!$opt_s!,
);

$| = 1;

getopts("wvas") or die "bad usage";

@ARGV = @INC unless @ARGV;

use vars (
    q!$Start_Dir!,
    q!%Future!,
);

my $Module;

if ($opt_s) {
    if (open(ME, "-|")) {
        $/ = "";
        while (<ME>) {
            chomp;
            print join("\n", sort split /\n/), "\n";
        }
        exit;
    }    
}

MAIN: {
    my %visited;
    my ($dev, $ino);
    
    @Future{@ARGV} = (1) x @ARGV;
    
    foreach $Start_Dir (@ARGV) {
        delete $Future{$Start_Dir};
        
        print "\n << Modules from $Start_Dir>>\n\n" if $opt_v;
        
        next unless ($dev, $ino) = stat($Start_Dir);
        next if $visited{$dev, $ino}++;
        next unless $opt_a || $Start_Dir =~ m!^/!;
        
        find(\&wanted, $Start_Dir);
    }
    
    exit;
}

sub modname {
    local $_ = $File::Find::name;
    
    if (index($_, $Start_Dir . "/") == 0) {
        substr($_, 0, 1 + length($Start_Dir)) = "";
    }
    
    s{/}{::}gx;
    s{\.p(m|od)$}{}x;
    
    return $_;
}

sub wanted {
    if ($Future{$File::Find::name}) {
        warn "\t(Skipping $File::Find::name, qui venit in futuro.)\n" if 0 and $opt_v;
        $File::Find::prune = 1;
        return;
    }
    
    return unless /\.pm$/ && -f;
    $Module = &modname;
    
    if ($Module =~ /^CPAN(\Z|::)/) {
        warn("$Module -- skipping because it misbehaves\n");
        return;
    }
    
    my $file = $_;

    unless (open(POD, "<", $file)) {
        warn "\tcannot open $file: $!";
        return 0;
    }
    
    $: = " -:";
    
    local $/ = "";
    local $_;
    
    while (<POD>) {
        if (/=head\d\s+NAME/) {
            chomp($_ = <POD>);
            s/^.*?--\s+//s;
            s/\n/ /g;
            
            my $v;
            
            if (defined($v = getversion($Module))) {
                print "$Module ($v) ";
            } else {
                print "$Module ";
            }
            
            print "- $_\n";
            return 1;            
        }
    }
    
    warn "\t(MISSING DESC FOR $File::Find::name)\n" if $opt_w;
    
    return 0;
}

sub getversion {
    my $mod = shift;
    
    my $vers = `$^X -m$mod -e 'print \$${mod}::VERSION' 2>/dev/null`;
    $vers =~ s/^\s*(.*?)\s*$/$1/;
    return ($vers || undef);
}