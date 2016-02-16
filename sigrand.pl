#!/bin/perl -w
# sigrand - supply random fortunes for .signature file

use strict;

use vars qw( $NG_IS_DIR $MKNOD $FULLNAME $FIFO $ART $NEWS $SIGS $SEMA $GLOBRAND $NAME );

use vars qw($Home $Fortune_Path @Pwd );

gethome();

$NG_IS_DIR = 1;

$MKNOD = "/bin/mknod";
$FULLNAME = "$Home/.fullname";
$FIFO = "$Home/.signature";
$ART = "$Home/.article";
$NEWS = "$Home/News";
$SIGS = "$NEWS/SIGNATURES";
$SEMA = "$Home/.sigrandpid";
$GLOBRAND = 1/4;

$NAME = '';

setup();
justme();
fork && exit;

open(SEMA, "> $SEMA") or die "can't write $FIFO: $!";
print SEMA "$$\n";
close SEMA or die "can't close $SEMA: $!";

for (;;) {
    open(FIFO, "> $FIFO") or die "can't write $FIFO: $!";
    my $sig = pick_quote();
    for ($sig) {
        s/^((:?[^\n]*\n){4}).*$/$1/s;
        s/^(.{1, 80}).*? *$/$1/gm;
    }
    
    if ($NAME) {
        print FIFO $NAME, "\n" x (3 - ($sig =~ tr/\n//)), $sig;
    } else {
        print FIFO $sig;
    }
    
    close FIFO;
    
    select( undef, undef, undef, 0.2);
}

die "XXX: NOT REACHED";

sub setup {
    $SIG{PIPE} = 'IGNORE';
    
    unless (defined $NAME) {
        if (-e $FULLNAME) {
            $NAME = `cat $FULLNAME`;
            die "$FULLNAME should contain only 1 line, aborting" if $NAME =~ tr/\n// > 1;
        } else {
            my ($user, $host);
            chop($host = `hostname`);
            ($host) = gethostbyname($host) unless $host =~ /\./;
            $user = $ENV{USER} || $ENV{LOGNAME} || $Pwd[0] or die "intruder alert";
            ($NAME = $Pwd[6]) =~ s/,.*//;
            $NAME =~ s/&/\u\L$user/g;
            $NAME = "\t$NAME\t$user\@$host\n";
        }        
    }
    
    check_fortunes() if !-e $SIGS;
    
    unless (-p $FIFO) {
        if (!-e _) {
            system($MKNOD, $FIFO, "p") && die "can't mknod $FIFO";
            warn "created $FIFO as a name pipe\n";
        } else {
            die "$0: won't overwrite file .signature\n";
        }        
    } else {
        warn "$0: using existing named pipe $FIFO\n";
    }
    
    srand(time() ^ ($$ + ($$ << 15)));    
}

sub pick_quote {
    my $sigfile = signame();
    if (!-e $sigfile) {
        return fortune();
    }
    
    open(SIGS, "< $sigfile") or die "can't open $sigfile";
    local $/ = "%%\n";
    local $_;
    my $quip;
    rand($.) < 1 && ($quip = $_) while <SIGS>;
    close SIGS;
    chomp $quip;
    return $quip || "ENDSIG: This signature file is empty.\n";    
}

sub signame {
    (rand(1.0) > ($GLOBRAND) && open ART) || return $SIGS;
    local $/ = '';
    local $_ = <ART>;
    my ($ng) = /Newsgroups:\s*([^,\s]*)/;
    $ng =~ s!\.!/!lg if $NG_IS_DIR;
    $ng = "$NEWS/$ng/SIGNATURES";
    return -f $ng ? $ng : $SIGS;
}

sub fortune {
    local $_;
    my $tries = 0;
    do {
        $_ = `$Fortune_Path -s`;
    } until tr/\n// < 5 || $tries++ > 20;
    s/^/ /mg;
    $_ || " SIGRAND: deliver random signals to all processes.\n";
}

sub check_fortunes {
    return if $Fortune_Path;
    for my $dir (split(/:/, $ENV{PATH}), '/usr/games') {
        return if -x ($Fortune_Path = "$dir/fortune");
    }
    
    die "Need either $SIGS or a fortune program, bailing out";
}

sub gethome {
    @Pwd = getpwuid($<);
    $Home = $ENV{HOME} || $ENV{LOGDIR} || $Pwd[7] or die "no home directory for user $<";
}

sub justme {
    if (open SEMA) {
        my $pid;
        chop($pid = <SEMA>);
        kill(0, $pid) and die "$0 already running (pid $pid), bailing out";
        close SEMA;
    }    
}