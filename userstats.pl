#!/bin/perl -w
# userstats - generates statistics on who is logged in.
# call with an argument to display totals

use DB_File;

$db = "/tmp/userstats.db";

tie(%db, 'DB_File', $db) or die "Can't open DB_File $db : $!\n";

if (@ARGV) {
    if ("@ARGV" eq "ALL") {
        @ARGV = sort keys %db;
    }
    
    foreach $user (@ARGV) {
        print "$user\t$db{$user}\n";
    }
} else {
    @who = `who`;
    if ($?) {
        die "Couldn't run who: $?\n";
    }
    foreach $line (@who) {
        $line =~ /^(\S+)/;
        die "Bad line from who: $line\n" unless $1;
        $db{$1}++;
    }    
}

untie %db;
