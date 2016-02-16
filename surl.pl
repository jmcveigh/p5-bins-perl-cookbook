#!/bin/perl -w
# surl - sort URLs by their last modification date
use strict;
use LWP::UserAgent;
use HTTP::Request;
use URI::URL qw(url);

my %Date;
my $ua = LWP::UserAgent->new();
while (my $url = url(scalar <>)) {
    my $ans;
    next unless $url->scheme =~ /^(file|https?)$/;
    $ans = $ua->head($url);
    if ($ans->is_success) {
        $Date{$url} = $ans->last_modified || 0;
    } else {
        warn("$url: Error [", $ans->code, "] ", $ans->message, "!\n");
    }    
}

foreach my $url (sort { $Date{$b} <=> $Date{$a} } keys %Date ) {
    printf "%-25s %s\n", $Date{$url} ? (scalar localtime $Date{$url}) : "<NONE SPECIFIED>", $url;
}
