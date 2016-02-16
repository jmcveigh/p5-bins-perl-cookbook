#!/bin/perl -00
# datesort - sort mbox by subject then date
use strict;
use Date::Manip;
my @msgs = ();
while (<>) {
    next unless /^From/m;
    my $date = '';
    
    if (/^Date:\s*(.*)/m) {
        ($date = $1) =~ s/\s+\(.*//;
        $date = ParseDate($date);
    }
    
    push @msgs, {
        SUBJECT => /^Subject:\s*(?:Re:\s*)*(.*)/mi,
        DATE => $date,
        NUMBER => scalar @msgs,
        TEXT => '',
    };    
} continue {
    $msgs[-1]{TEXT} .= $_;
}

for my $msg ( sort {
    $a->{SUBJECT} cmp $b->{SUBJECT} || $a->{DATE} cmp $b->{DATE} || $a->{NUMBER} <=> $b->{NUMBER}
} @msgs) {
    print $msg->{TEXT};
}