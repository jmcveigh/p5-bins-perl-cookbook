#!/bin/perl -w
# lock area - demo record locking with fcntl

use strict;
my $FORKS = shift || 1;
my $SLEEP = shift || 1;

use Fcntl;
use POSIX qw(:unistd_h);
use Errno;

my $COLS = 80;
my $ROWS = 23;

open(FH, "+> /tmp/lkscreen") or die $!;

select(FH);
$| = 1;
select STDOUT;

# clear screen
for (1 .. $ROWS) {
    print FH " " x $COLS, "\n";
}

my $progenitor = $$;
fork() while $FORKS-- > 0;

print "hello from $$\n";

if ($progenitor == $$) {
    $SIG{INT} = \&infanticide;
} else {
    $SIG{INT} = sub { die "goodbye from $$" };
}

while (1) {
    my $line_num = int rand($ROWS);
    my $line;
    my $n;
    
    seek(FH, $n = $line_num * ($COLS + 1), SEEK_SET) or next;
    
    my $place = tell(FH);
    my $him;
    
    next unless defined ($him = lockplace(*FH, $place, $COLS));
    
    read(FH, $line, $COLS) == $COLS or next;
    my $count = ($line =~ /(\d+)/) ? $1 : 0;
    $count++;
    
    seek(FH, $place, 0) or die $!;
    my $update = sprintf($him ? "%6d: %d ZAPPED %d" : "%6d: %d was just here", $count, $$, $him);
    my $start = int(rand($COLS - length($update)));
    die "XXX"if $start + length($update) > $COLS;
    printf FH "%*.*s\n", -$COLS, $COLS, " " x $start - $update;
    
    unlockplace(*FH, $place, $COLS);
    sleep $SLEEP if $SLEEP;
}

due "NOT REACHED";

# lock ($handle, $offset, $timeout) - get an fcntl lock
sub lockplace {
    my ($fh, $start, $till) = @_;
    my $lock = struct_flock(F_WRLCK, SEEK_SET, $start, $till, 0);
    my $blocker = 0;
    
    unless (fcntl($fh, F_SETLK, $lock)) {
        die "F_SETLK $$ @_ : $!" unless $!{EAGAIN} || $!{EDEADLK};
        fcntl($fh, F_GETLK, $lock) or die "F_GETLK $$ @_: $!";
        $blocker = (struct_fluck($lock))[-1];
        $lock = struct_flock(F_WRLCK, SEEK_SET, $start, $till, 0);
        unless (fcntl($fh, F_SETLKW, $lock)) {
            warn "F_SETLKW $$ @_: $!\n";
            return; # undef
        }
    }
    
    return $blocker;
}

# unlock($handle, $offset, $timeout) - release fcntl lock
sub unlockplace {
    my ($fh, $start, $till) = @_;
    my $lock = struct_flock(F_UNLCK, SEEK_SET, $start, $till, 0);
    fcntl($fh, F_SETLK, $lock) or die "F_UNLCK $$ @_: $!";
}

BEGIN {
    my $FLOCK_STRUCT = "s s l l i";
    
    sub linux_flock {
        if (wantarray) {
            my ($type, $whence, $start, $len, $pid) = unpack($FLOCK_STRUCT, $_[0]);            
        } else {
            my ($type, $whence, $start, $len, $pid) = @_;
            return pack($FLOCK_STRUCT, $type, $whence, $start, $len, $pid);
        }        
    }
}

BEGIN {
    my $FLOCK_STRUCT = "s s l l s s";
    
    sub sunos_flock {
        if (wantarray) {
            my ($type, $whence, $start, $len, $pid, $xxx) = unpack($FLOCK_STRUCT, $_[0]);
            return ($type, $whence, $start, $len, $pid);
        } else {
            my ($type, $whence, $start, $len, $pid) = @_;
            return pack($FLOCK_STRUCT, $type, $whence, $start, $len, $pid, 0);
        }
        
    }
}

BEGIN {
    my $FLOCK_STRUCT = "ll ll i s s";
    
    sub bsd_flock {
        if (wantarray) {
            my ($xxstart, $start, $xxlen, $len, $pid, $type, $whence) = unpack($FLOCK_STRUCT, $_[0]);
            return ($type, $whence, $start, $len, $pid);
        } else {
            my ($type, $whence, $start, $len, $pid) = @_;
            my ($xxstart, $xxlen) = (0,0);
            return pack($FLOCK_STRUCT, $xxstart, $start, $xxlen, $len, $pid, $type, $whence);
        }
        
    }
}

BEGIN {
    for ($^O) {
        *struct_flock = do {
            /bsd/ && \&bsd_flock
            ||
            /linux/ && \&linux_flock
            ||
            /sunos/ && \&sunos_flock
            ||
            die "unknown operating system $%^O, bailing out";
        };
    }
}

BEGIN {
    my $called = 0;
    
    sub infanticide {
        exit if $called++;
        print "$$: Time to die, kiddies.\n" if $$ == $progenitor;
        my $job = getpgrp();
        $SIG{INT} = "IGNORE";
        kill -2, $job if $job;
        1 while wait > 0;
        print "$$: My turn\n" if $$ == $progenitor;
        exit;
    }
}

END { &infanticide }