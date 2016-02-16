#!/bin/perl
# cmd3sel - control all three of kids in, out, and error.
use IPC::Open3;
use IO::Select;

$cmd = "grep vt33 /none/such - /etc/termcap";
$pid = open3($cmd_in, $cmd_out, $cmd_err, $cmd);

$SIG{CHLD} = sub {
    print "REAPER: status $? on $pid\n" if waitpid($pid, 0) > 0
};

print $cmd_in "This line has a vt33 lurking in it\n";
close $cmd_in;

$selector = IO::Select->new();
$selector->add($cmd_err, $cmd_out);

while (@ready = $selector->can_read) {
    foreach $fh (@ready) {
        if (fileno($fh) == fileno($cmd_err)) {
            print "STDERR: ", scalar <$cmd_err>;
        } else {
            $selector->remove($fh) if eof($fh);
        }        
    }
}

close $cmd_out;
close $cmd_err;
