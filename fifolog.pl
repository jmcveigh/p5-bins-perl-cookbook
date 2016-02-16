#!/bin/perl
# fifolog - read and record log msgs from fifo

$SIG{ALRM} = sub {
    close(FIFO);
};

while (1) {
    alarm(0);
    open($fifo, "</tmp/log") or die "Can't open /tmp/log : $!\n";
    alarm(1);
    
    $service = <$fifo>;
    next unless defined $service;
    chomp $service;
    
    $message = <$fifo>;
    next unless defined $message;
    
    chomp $message;
    
    alarm(0);
    
    if ($service eq "http") {
        #code
    } elsif ($service eq "login") {
        if (open($log, ">> /tmp/login")) {
            print $log scalar(localtime), " $service $message\n";
            close $log;
        } else {
            warn "Couldn't log $service $message to /var/log/login: $!\n";
        }        
    }    
}
