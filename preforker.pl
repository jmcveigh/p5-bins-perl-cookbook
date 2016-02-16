#!/bin/perl
# preforker - server who forks first
use IO::Socket;
use Symbol;
use POSIX;

$server = IO::Socket::INET->new(LocalPort => 69, Type => SOCK_STREAM, Proto => 'tcp', Reuse => 1, Listen => 10) or die "making socket: $@\n";

$PREFORK = 5;
$MAX_CLIENTS_PER_CHILD = 5;
%children = ();
$children = 0;

sub REAPER {
    $SIG{CHLD} = \&REAPER;
    my $pid = wait;
    $children--;
    delete $children{$pid};
}

sub HUNTSMAN {
    local($SIG{CHLD}) = 'IGNORE';
    kill 'INT' => keys %children;
    exit;
}

for (1 .. $PREFORK) {
    make_new_child();
}

$SIG{CHLD} = \&REAPER;
$SIG{INT} = \&HUNTSMAN;

while (1) {
    sleep;
    for ($i = $children; $i < $PREFORK; $i++) {
        make_new_child();
    }
}

sub make_new_child {
    my $pid;
    my $sigset;
    
    $sigset = POSIX::SigSet->new(SIGINT);
    sigprocmask(SIG_BLOCK, $sigset) or die "Can't block SIGINT for fork: $!\n";
    
    die "fork: $!" unless defined ($pid = fork);
    
    if ($pid) {
        sigprocmask(SIG_UNBLOCK, $sigset) or die "Can't block SIGINT for fork: $!\n";
        $children{$pid} = 1;
        $children++;
        return;    
    } else {
        $SIG{INT} = 'DEFAULT';
        
        sigprocmask(SIG_UNBLOCK, $sigset) or die "Can't unblock SIGINT for fork: $!\n";
        
        for ($i = 0; $i < $MAX_CLIENTS_PER_CHILD; $i++) {
            $client = $server->accept() or last;
            
            # do something with the connection
        }
        
        exit;
    }
}