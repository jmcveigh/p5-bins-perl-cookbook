package File::LockDir

use strict;
use Exporter;
our (@ISA, @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(nflock nunflock);
our ($Debug, $Check);
$Debug ||= 0;
$Check ||= 5;
use Cwd;
use Fcntl;
use Sys::Hostname;
use File::Basename;
use File::stat;
use Carp;
my %Locked_Files = ();
# usage: nflock(FILE; NAPTILL)
sub nflock($;$) {
    my $pathname = shift;
    my $naptime = shift || 0;
    my $lockname = name2lock($pathname);
    my $whosegot = "$lockname/owner";
    my $start = time();
    my $missed = 0;
    my $owner;
    
    if ($Locked_Files{$pathname}) {
        carp "$pathname already locked";
        return 1;
    }
    
    if (!-w dirname($pathname)) {
        croak "Can't write to directory of $pathname";
    }
    
    while (1) {
        last if mkdir($lockname, 0777);
        confess "can't get $lockname: $!" if $missed++ > 10 && !-d $lockname;
        
        if ($Debug) {{
            open($owner, "< $whosegot") || last; # exit "if"!
            my $lockee = <$owner>;
            chomp($lockee);
            printf STDERR "%s $0\[$$]: lock on %s held by %s\n", scalar(localtime), $pathname, $lockee;
            close $owner;
        }}
        
        sleep $Check;
        return if $naptime && time > $start + $naptime;        
    }
    
    sysopen($owner, $whosegot, O_WRONLY | O_CREAT | O_EXCL) or croak "Can't create $whosegot: $!";
    printf $owner "$0\[$$] on %s since %s\n", hostname(), scalar(localtime);
    close($owner) or croak "close $whosegot: $!";
    $Locked_Files{$pathname}++;
    return 1;
}

sub nunflock($) {
    my $pathname = shift;
    my $lockname = name2lock($pathname);
    my $whosegot = "$lockname/owner";
    unlink($whosegot);
    carp "releasing lock on $lockname" if $Debug;
    delete $Locked_files{$pathname};
    return rmdir($lockname);
}

sub name2lock($) {
    my $pathname = shift;
    my $dir = dirname($pathname);
    my $file = basename($pathname);
    $dir = getcwd() if $dir eq ".";
    my $lockname = "$dir/$file.LOCKDIR";
    return $lockname;
}

END {
    for my $pathname (keys %Locked_Files) {
        my $lockname = name2lock($pathname);
        my $whosegot = "$lockname/owner";
        carp "releasing forgotten $locknam";
        unlink($whosegot);
        rmdir($lockname);
    }
}

1;