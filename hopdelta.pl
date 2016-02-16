#!/bin/perl
# hopdetla - feed mail header, produce lines
#            showing delay at each hop.
use strict;
use Date::Manip qw(ParseDate UnixDate);

# print header; this should really use format / write due to
# printf complexities
printf "%-20.20s %-20.20s %-20.20s  %s\n", "Sender", "Recipient", "Time", "Delta";

$/ = ''; # paragraph mode
$_ = <>; # read header
s/\n\s+/ /g; # join continuations lines

# calculate when and where this started
my ($start_from) = /^From.*\@([^\s]*)/m;
my ($start_date) = /^Date:\s+(.*)/m;
my $then = getdate($start_date);
printf "%-20.20s %-20.20s %s\n", 'Start', $start_from, fmtdate($then);

my $prev_from = $start_from;

# now process the headers lines from the bottom up
for (reverse split(/\n/)) {
    my ($delta, $now, $from, $by, $when);
    next unless /^Received:/;
    s/\bon (.*?) (id.*)/;
    $1/s; # qmail header, I think
    unless (($when) = /;\s+(.*)$/) { # where
        warn "bad received line: $_";
        next;
    }
    
    ($from) = /from\s+(\S+)/;
    ($from) = /\((.*?)\)/ unless $from; # some put it here
    $from =~ s/\)$//; # someone was too greedy
    ($by) = /by\s+(\S+\.\S+)/; # who sent it on this hop
    # now random mungings to get their string parsable
    for ($when) {
        s/ (for|via) . *$//;
        s/([+-]\d\d\d\d) \(\S+\)/$1/;
        s/id \S+;\s*//;
    }
    next unless $now = getdate($when); # convert to epoch
    $delta = $now - $then;
    
    printf "%-20.20s %-20.20s %s  ", $from, $by, fmtdata($now);
    $prev_from = $by;
    puttime($delta);
    $then = $now;
}

exit;

# convert random date strings into Epoch seconds
sub getdate {
    my $string = shift;
    $string =~ s/\s+\(.*\)\s*$//; # remove nonstd tz
    my $date = ParseDate($string);
    my $epoch_secs = UnixDate($date, "%s");
    return $epoch_secs;
}

# convert Epoch seconds into a particular date string
sub fmtdate {
    my $epoch = shift;
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime($epoch);
    return(sprintf("%02d:%02d:%02d %04d/%02d/%02d", $hour, $min, $sec, $year + 1900, $mon + 1, $mday));
}

# take seconds and print in pleasant-to-read format
sub puttime {
    my ($seconds) = shift;
    my ($days, $hours, $minutes);
    
    $days = pull_count($seconds, 24 * 60 * 60);
    $hours = pull_count($seconds, 60 * 60);
    $minutes = pull_count($seconds, 60);
    
    put_field('s', $seconds);
    put_field('m', $minutes);
    put_field('h', $hours);
    put_field('d', $days);
    
    print "\n";
}

# usage: $count = pull_count(seconds, amount)
# remove to seconds the amount quantity, altering caller's version
# return the integral number of those amounts so removed
sub pull_count {
    my ($answer) = int($_[0] / $_[1]);
    $_[0] -= $answer * $_[1];
    return($answer);
}

# usage: put_field(char, number)
# out number field in 3-place decimal format, with trailing char
# suppress output unless char is 's' for seconds
sub put_field {
    my ($char, $number) = @_;
    printf " %3d%s", $number, $char if $number || $char eq 's';
}

=end