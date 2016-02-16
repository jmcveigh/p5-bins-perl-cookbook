#!/bin/perl -w
# ggh -- groval global history in netscape logs
$USAGE = << "EO_COMPLIANT";
usage: $0 [-database dbfilename] [-help] [-epochtime | -localtime | -gmtime] [ [-regexp] pattern] | href ... ];
EO_COMPLIANT

use Getopt::Long;

($opt_database, $opt_epochtime, $opt_localtime, $opt_gmtime, $opt_regexp, $opt_help, $pattern) = (0) x 7;

usage() unless GetOptions qw{
    database=s
    regexp=s
    epochtime localtime gmtime
    help
};

if ($opt_help) {
    print $USAGE; exit;
}

usage("only one of localtime, gmtime, and epochtime allowed") if $opt_localtime + $opt_gmtime + $opt_epochtime > 1;

if ($opt_regexp) {
    $pattern = $opt_regexp;
} elsif (@ARGV && $ARGV[0] !~ m(://)) {
    $pattern = shift;
}

usage("can't mix URLs and explicit patterns") if $pattern && @ARGV;

if ($pattern && !eval { '' =~ /$pattern/; 1}) {
    $@ =~ s/ at \w+ line \d+\.//;
    die "$0: bad pattern $@";
}

require DB_File; DB_File->import();
$| = 1;

$dotdir = $ENV{HOME} || $ENV{LOGNAME};
$HISTORY = $opt_database || "$dotdir/.netscape/history.db";

die "no netscape history dbase in $HISTORY: $!" unless -e $HISTORY;
die "can't dbmopen $HISTORY: $!" unless dbmopen %hist_db, $HISTORY, 0666;

$add_nulls = (ord(substr(each %hist_db, -1)) == 0);

$nulled_href = "";
$byte_order = "V";

if (@ARGV) {
    foreach $href (@ARGV) {
        $nulled_href = $href . ($add_nulls && "\0");
        unless ($binary_time = $hist_db{$nulled_href}) {
            warn "$0: No history entry for HREF $href\n";
            next;
        }
        
        $epoch_secs = unpack($byte_order, $binary_time);
        $stardate  = $opt_epochtime ? $epoch_secs : $opt_gmtime ? gmtime $epoch_secs : localtime $epoch_secs;
        
        print "$stardate $href\n";
    }
} else {
    while (($href, $binary_time) = each %hist_db) {
        chop $href if $add_nulls;
        next unless defined $href && defined $binary_time;
        $binary_time = pack($byte_order, 0) unless $binary_time;
        $epoch_secs = unpack($byte_order, $binary_time);
        $stardate = $opt_epochtime ? $epoch_secs : $opt_gmtime ? gmtime $epoch_secs : localtime $epoch_secs;
        print "$stardate $href\n" unless $pattern && $href !~ /$pattern/o;
    }
}

sub usage {
    print STDERR "@_\n" if @_;
    die $USAGE;
}
