#!/bin/perl -00
# bysub3 - sort by subject using hash records
use strict;
my @msgs = ();
while (<>) {
    push @msgs, {
        SUBJECT => /^Subject:\s*(?:Re:\s*)*(.*)/mi,
        NUMBER => scalar @msgs,
        TEXT => '',
    } if /^From/m;
    $msgs[-1]{TEXT} .= $_;
}

for my $msg (sort {
    $a->{SUBJECT} cmp $b->{SUBJECT} || $a->{NUMBER} <=> $b->{NUMBER}
} @msgs) {
    print $msg->{TEXT};
}