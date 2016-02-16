#!/bin/perl -w
# aprept - report on Apache logs

use Logfile::Apache;

$l = Logfile::Apache->new(
    File => "-", # STDIN
    Group => [ Domain, File ]
);

$l->report(Group => Domain, Sort => Records);
$l->report(Group => File, List => [Bytes, Records]);