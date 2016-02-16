#!/bin/perl -w
# dutree - print sorted indented rendition of du output
use strict;
my %Dirsize;
my %Kids;

getdots(my $topdir = input());
output($topdir);

sub input {
    my ($size, $name, $parent);
    @ARGV = ("du @ARGV |");
    while (<>) {
        ($size, $name) = split;
        $Dirsize{$name} = $size;
        ($parent = $name) =~ s#/[^/]+$##; # dirname
        push @{$Kids{$parent}}, $name unless eof;
    }
    
    return $name;
}

sub getdots {
    my $root = $_[0];
    my ($size, $cursize);
    $size = $cursize = $Dirsize{$root};
    if ($Kids{$root}) { 
        for my $kid (@{ $Kids{$root}}) {
            $cursize -= $Dirsize{$kid};
            getdots($kid);
        }
    }
    
}

sub output {
    my ($root, $prefix, $width) = (shift, shift || '', shift || 0);
    my $path;
    ($path = $root) =~ s#.*/##;
    my $size = $Dirsize{$root};
    my $line = sprintf("%${width}d %s", $size, $path);
    print $prefix, $line, "\n";

    for ($prefix .= $line) {
        s/\d /| /;
        s/[^|]/ /g;
    }
    
    if ($Kids{$root}) {
        my @Kids = @{ $Kids{$root} };
        @Kids = sort { $Dirsize{$b} <=> $Dirsize{$a} } @Kids;
        $Dirsize{$Kids[0]} =~ /(\d+)/;
        my $width = length $1;
        for my $kid (@Kids) {
            output($kid, $prefix, $width);
        }
    }
    
}