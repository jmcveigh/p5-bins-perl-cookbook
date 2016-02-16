#!/bin/perl -w
# rep - screen repeat command
use strict;
use Curses;

my $timeout = 10;
if (@ARGV && $ARGV[0] =~ /^-(\d+\.?\d*)$/) {
    $timeout = $1;
    shift;
}

die "usage: $0 [ -timeout ] cmd args\n" unless @ARGV;

initscr();
noecho();
cbreak();
nodelay(1);

$SIG{INT} = sub { done("Ouch!") };
sub done { endwin(); print "@_\n"; exit; }

while (1) {
    while ((my $key = getch() ne ERR)) {
        done("See ya") if $key eq 'q';
    }
    
    my @data = `(@ARGV) 2>&1`;
    
    for (my $i = 0; $i < $LINES; $i++) {
        addstr($i, 0, $data[$i] || ' ' x $COLS);
    }
    
    standout();
    addstr($LINES - 1, $COLS - 24, scalar localtime);
    standend();
    move(0,0);
    refresh();
    
    my ($in, $out) = ('', '');
    vec($in, fileno(STDIN),1) = 1;
    select($out = $in, undef, undef, $timeout);
}

