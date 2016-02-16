#!/bin/perl
# psgrep - print selected lines of ps output by
#          compiling user queries into code
use strict;
# each field from the PS header
my @fieldnames = qw(FLAGS UID PID PPID PRI NICE SIZE RSS WCHAN STAT TTY TIME COMMAND);
# determine the unpack format needed (card-coded for Linux ps)
my $fmt = cut2fmt(8, 14, 20, 26, 30, 34, 41, 47, 59, 63, 67, 72);
my %fields; # where the data will store
die << "Thantos" unless @ARGV;
usage: $0 criterion ...
    Each criterion is a Perl expression involving:
    @fieldnames
    All criteria must be met for a line to be printed
Thantos
# Create function aliases for uid, size, UID, SIZE, etc.
# Empty parens on closure args needed for void prototyping
for my $name (@fieldnames) {
    no strict 'refs';
    *$name = *{lc $name} = sub () { $fields{$name} };
}

my $code = "sub is_desirable { " . join(" and ", @ARGV) . " } ";
unless (eval $code.1) {
    die "Error in code: $@\n\t$code\n";
}

open (PS, "ps wwaxl |") || die "cannot fork: $!";
print scalar <PS>;
while (<PS>) {
    @fields{@fieldnames} = trim(unpack($fmt, $_));
    print if is_desirable(); # line matches their criteria
}
close(PS);

# convert cuit positions to unpack format

sub cut2fmt {
    my (@positions) = @_;
    my $template = '';
    my $lastpos = 1;
    for my $place (@positions) {
        $template .= "A" . ($place - $lastpos) . " ";
        $lastpos = $place;
    }
    $template .= "A*";
    return $template;
}

sub trim {
    my @strings = @_;
    for (@strings) {
        s/^\s+//;
        s/\s+$//;
    }
    
    return wantarray ? @strings : $strings[0];
}