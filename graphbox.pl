#!/bin/perl -w
# graphbox - graph number of messages by day of week they were sent

use GD::Graph::bars;
use Getopt::Std;
use strict;

my %count;
my $chart;
my $plot;

my @DAYS = qw(Mon Tue Wed Thu Fri Sat Sun);
my $day_re = join("|", @DAYS);
$day_re = qr/$day_re/;

my %Opt;
getopts('ho:', \%Opt);
if ($Opt{h} or !$Opt{o}) { 
    die "Usage:\n\t$0 -o outfile.png < mailbox\n";
}

while (<>) {
    if (/^Date: .*($day_re)/) {
        $count{$1}++;
    }    
}

$chart = GD::Graph::bars->new(480, 320);
$chart->set(x_label => "Day", y_label => "Messages", title => "Mail Activity");
$plot = $chart->plot(
    [
        [@DAYS],
        [@count{@DAYS}],
    ]
);

open(F, "> $Opt{o}") or die "Can't open $Opt{o} for writing: $!\n";
print F $plot->png;
close F;
