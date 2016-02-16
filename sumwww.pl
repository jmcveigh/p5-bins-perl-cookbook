#!/bin/perl
# sumwww - summarize web server log activity

$lastdate = "";
daily_logs();
summary();
exit;

# read CLF files and tally hits from the host and to the URL
sub daily_logs {
    while (<>) {
        ($type, $what) = /"(GET|POST)\s+(\S+?) \S+"/ or next;
        ($host, undef, undef, $datetime) = split;
        ($bytes) = /\s(\d+)\s*$/ or next;
        ($date) = ($datetime =~ /\[([^:]*)]/);
        $posts += ($type eq POST);
        $home++ if m, / ,;
        if ($date ne $lastdate) {
            if ($lastdate) {
                write_report();
            } else {
                $lastdate = $date;
            }            
        }
        $count++;
        $hosts{$host}++;
        $what{$what}++;
        $bytesum += $bytes;
    }
    
    write_report() if $count;    
}

# use *typeglob aliasing of global variables for cheap copy
sub summary {
    $lastdate = "Grand Total";
    *count = *sumcount;
    *bytesum = *bytesumsum;
    *hosts = *allhosts;
    *posts = *allhosts;
    *what = *allwhat;
    *home = *allhome;
    write;
}

# display the tallies of hosts and URLs, using formats

sub write_report {
    write;
    
    # add to summary data
    $lastdate = $date;
    $sumcount += $count;
    $bytesumsum += $bytesum;
    $allposts += $posts;
    $allhome += $home;
    
    # reset daily data
    $posts = $count = $bytesum = $home = 0;
    @allwhat{keys %what} = keys %what;
    @allhosts{keys %hosts} = keys %hosts;
    %hosts = %what = ();
}

format STDOUT_TOP =
@|||||||||||| @|||||| @|||||| @||||||| @|||||| @|||||| @||||||||||||
"Date",      "Hosts", "Accesses", "Unidocs", "POST", "Home", "Bytes"
------------ ------- ------- ------- ------- ------- -------------
.

format STDOUT =
@>>>>>>>>>>>> @>>>>>> @>>>>>>> @>>>>>>> @>>>>>> @>>>>>> @>>>>>>>>>>>
$lastdate, scalar(keys %hosts), $count, scalar(keys %what),
                    $posts, $home, $bytesum
.