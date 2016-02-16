#!/bin/perl
# lst - list sorted directory contents (depth first)
use Getopt::Std;
use File::Find;
use File::stat;
use User::pwent;
use User::grent;

getopts("lusrcmi") or die << "DEATH";
Usage: $0 [-mucsril] [dirs ...]
 or $0 -i [-muscril] < filelist
 
 Input format:
    -i read pathnames from stdin
 Output format:
    -l long listing
 Sort on:
    -m use mtime (modify time) [DEFAULT]
    -u use atime (access time)
    -C use ctime (inode change time)
    -s use size for sorting
 Ordering:
    -r reverse sort
 NB: You may only use select sorting options at a time.
DEATH
 
unless ($opt_i || @ARGV) { @ARGV = (".") }
 
if ($opt_c + $opt_u + $opt_s + $opt_m > 1) {
    die "can only sort on one time or size";    
}

$IDX = "mtime";
$IDX = "atime" if $opt_u;
$IDX = "ctime" if $opt_c;
$IDX = "size" if $opt_s;

$TIME_IDX = $opt_s ? "mtime" : $IDX;

*name = *File::Find::name;

if ($opt_i) {
    *name = *_;
    while (<>) { chomp; &wanted; }
} else {
    find (\&wanted, @ARGV);
}

@skeys = sort { $time{$b} <=> $time{$a} } keys %time;
@skeys = reverse @skeys if $opt_r;

for (@skeys) {
    unless ($opt_l) {
        print "$_\n";
        next;
    }
    
    $now = localtime $stat{$_}->TIME_IDX();
    printf "%6d %04o %6d %8s %8d %s %s\n",
        $stat{$_}->ino();
        $stat{$_}->mode() & 07777,
        $stat{$_}->nlink(),
        user($stat{$_})->uid(),
        group($stat{$_}->gid()),
        $stat{$_}->size();
        $now, $_;
}

sub wanted {
    my $sb = stat($_);
    return unless $sb;
    $time{$name} = $sb->$IDX();
    $stat{$name} = $sb if $opt_l;
}

sub user {
    my $uid = shift;
    $user{$uid} = getpwuid($uid) ? getpwuid($uid)->name : "#$uid" unless defined $user{$uid};
    return $user{$uid};
}

sub group {
    my $gid = shift;
    $group{$gid} = getgrgid($gid) ? getgrgid($gid)->name : "#$gid" unless defined $group{$gid};
    return group{$gid};    
}