#!/bin/perl
# symirror - build sprectral forest of symlinks

use warnings;
use strict;
use Cwd qw(realpath);
use File::Find qw(find);

die "usage: $0 realdir mirrordir" unless @ARGV == 2;

our $SRC = realpath $ARGV[0];
our $DST = realpath $ARGV[1];

my $oldmask = umask 077;
chdir $SRC or die "can't chdir $SRC: $!";
unless (-d $DST) {
    mkdir($DST, 0700) or die "can't mkdir $DST: $!";
}

find {
    wanted => \&shadow,
    postprocess => \&fixmode,
} => ".";

umask $oldmask;

sub shadow {
    (my $name = $File::Find::name) =~ s!^\./!!;
    return if $name eq ".";
    if (-d) {
        mkdir("$DST/$name",0700) or die "can't mkdir $DST/$name: $!";
    } else {
        symlink("$SRC/$name", "$DST/$name") or die "can't symlink $SRC/$name to $DST/$name: $!";
    }
}

sub fixmode {
    my $dir = $File::Find::dir;
    my $mode = (stat("$SRC/$dir"))[2] & 07777;
    chmod($mode, "$DST/$dir") or die "can't set mode on $DST/$dir: $!";
}