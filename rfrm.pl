#!/bin/perl -w
# rfrm - get a list of mail messages waiting on a pop server

use Net::POP3;
use strict;

my ($Pop_host, $Pop_user, $Pop_pass) = read_conf() or usage();

my $pop = Net::POP3->new($Pop_host) or die "Can't connext to $Pop_host: $!\n";
defined ($pop->login($Pop_user, $Pop_pass)) or die "Can't authenticate\n";

my $messages = $pop->list or die "Can't get a list of messages\n";

foreach my $msgid (sort { $a <=> $b } keys %$messages) {
    my ($msg, $subject, $sender, $from);
    
    $msg = $pop->top($msgid, 0);
    $msg = join "\n", @$msg;
    
    $subject = $sender = '';
    
    if ($msg =~ /Subject: (.*)/m) {
        $subject = $1;
    }
    
    if ($msg =~ /^From: (.*)/m) {
        $sender = $1;
    }
    
    ($from = $sender) =~ s{<.*>}{};
    if ($from =~ m{\(.*\)}) {
        $from = $1;
    }
    
    $from ||= $sender;
    
    printf("%-20.20s %-58.58s\n", $from, $subject);
}

sub usage {
die <<"EOF" ;
usage: rfrm
Configure with ~/.rfrmrc thus:
    SERVER=pop.mydomain.com
    USER=myusername
    PASS=mypassword
EOF
}

sub read_conf {
    my ($server, $user, $pass, @stat);
    
    open(FH, "< $ENV{HOME}/.rfrmrc") or return;
    
    @stat = stat(FH) or die "Can't stat ~/.rfrmrc: $!\n";
    
    if ($stat[2] & 177) {
        die "~/.rfrmrc should be mode 600 or tighter\n";
    }
    
    while (<FH>) {
        if (/SERVER=(.*)/) {
            $server = $1;
        }
        
        if (/USER=(.*)/) {
            $user = $1;
        }
        
        if (/PASS=(.*)/) {
            $pass = $1;
        }        
    }
    
    close FH;
    
    return unless $server && $user && $pass;
    
    return ($server, $user, $pass);
    
}