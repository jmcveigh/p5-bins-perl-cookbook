#!/bin/perl -w
# dateplan - place current date and time in .plan file

while (1) {
    open($fifo, "> $ENV{HOME}/.plan") or die "Couldn't open $ENV{HOME}/.plan for writing: $!\n";
    print $fifo "The current time is ", scalar(localtime), "\n";
    close $fifo;
    sleep 1;
}