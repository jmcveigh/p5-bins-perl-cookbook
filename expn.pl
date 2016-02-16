#!/bin/perl -w
# expn -- convince smtp to divulge an alias expansion

use strict;
use Net::SMTP;
use Sys::Hostname;

my $fetch_mx = 0;

eval {
    require Net::DNS;
    Net::DNS->import('mx');
    $fetch_mx = 1;
};

my $selfname = hostname();
die "usage: $0 address\@host ...\n" unless @ARGV;

my $VERB = ($0 =~ /ve?ri?fy$/i) ? 'VRFY' : 'EXPN';

my $multi = @ARGV > 1;

my $remote;

foreach my $combo (@ARGV) {
    my ($name, $host) = split(/\@/, $combo);
    my @hosts;
    $host ||= 'localhost';
    @hosts = map { $_->exchange } mx($host) if $fetch_mx;
    
    @hosts = ($host) unless @hosts;
    
    foreach my $host (@hosts) {
        print $VERB eq 'VRFY' ? 'Verify' : 'Expand', "ing $name at $host ($combo):";
        $remote = Net::SMTP->new($host, Hello => $selfname);
        unless ($remote) {
            warn "cannot connect to $host\n";
            next;
        }
        
        print "\n";
        
        if ($VERB eq 'VRFY') {
            $remote->verify($name);
        } elsif ($VERB eq 'VRFY') {
            $remote->verify($name);
        } elsif ($VERB eq 'EXPN') {
            $remote->expand($name);
        }
        
        last if $remote->code == 221;
        next if $remote->code == 220;
        
        print $remote->message;
        $remote->quit;
        
        print "\n" if $multi;
    }
}