#!/bin/perl -w
# fwdport -- act as proxy forwarder for dedicated services
use strict; # require delcarations
use Getopt::Long; # for option processing
use Net::hostent; # by-name interface for host info
use IO::Socket; # for creating server and client sockets
use POSIX ":sys_wait_h"; # for reaping our dead children

my (
        %Children, # hash of outstanding child processes
        $REMOTE, # whom we connect to on the outside
        $LOCAL, # where we listen to on the inside
        $SERVICE, # our service name or port number
        $proxy_server, # the socket we accept() from
        $ME,
);

($ME = $0) =~ s,.*/,,; # retain just basename of script
check_args();
start_proxy();
service_clients();
die "NOT REACHED";

sub check_args {
    GetOptions(
            "remote=s" => \$REMOTE,
            "local=s" => \$LOCAL,
            "service=s" => \$SERVICE,
    ) or die <<EOUSAGE;
    usage: $0 [ --remote host ] [ --local interface ] [ --service service ]    
EOUSAGE

    die "Need remote" unless $REMOTE;
    die "Need local or service" unless $LOCAL || $SERVICE;
}

sub start_proxy {
    my @proxy_server_config = (
        Proto => 'tcp',
        Reuse => 1,
        Listen => SOMAXCONN,
    );
    push @proxy_server_config, LocalPort => $SERVICE if $SERVICE;
    push @proxy_server_config, LocalAddr => $LOCAL if $LOCAL;
    $proxy_server = IO::Socket::INET->new(@proxy_server_config) or die "can't create proxy serer: $@";
    print "[ Proxy server on ", ($LOCAL || $SERVICE), " initialized.]\n";
}

sub service_clients{
    my (
        $local_client,
        $lc_info,
        $remote_server,
        @rs_config,
        $rs_info,
        $pidpid,
    );
    
    $SIG{CHLD} = \&REAPER;
    
    accepting();
    
    while ($local_client = $proxy_server->accept()) {
        $lc_info = peerinfo($local_client);
        set_state("servicing local $lc_info");
        printf "[Connect from $lc_info]\n";
        
        @rs_config = (
            Proto => 'tcp',
            PeerAddr => $REMOTE,
        );
        
        push(@rs_config, PeerPort => $SERVICE) if $SERVICE;
        
        print "[Connecting to $REMOTE... ";
        
        set_state("connecting to $REMOTE");
        $remote_server = IO::Socket::INET->new(@rs_config) or die "remote server: $@";
        print "done]\n";
        
        $rs_info = peerinfo($remote_server);
        set_state("connected to $rs_info");
        
        my $kidpid = fork();
        die "Cannot fork" unless defined $kidpid;
        
        if ($kidpid) {
            $Children{$kidpid} = time();
            close $remote_server;
            close $local_client;
            next;
        }
        
        close $proxy_server;
        $kidpid = fork();
        die "Cannot fork" unless defined $kidpid;
        
        if ($kidpid) {
            set_state("$rs_info --> $lc_info");
            select($local_client); $| = 1;
            print while <$remote_server>;
            kill('TERM', $kidpid); # kill my twin cause we're done
        } else {
            set_state("$rs_info < -- $lc_info");
            select($remote_server); $| = 1;
            print while <$local_client>;
            kill('TERM', getpid()); # kill my twin cause we're done
        }
        exit;
    } continue {
        accepting();
    }    
}

sub peerinfo {
    my $sock = shift;
    my $hostinfo = gethostbyaddr($sock->peeraddr);
    return sprintf("%s:%s", $hostinfo->name || $sock->peerport, $sock->peerport);
}

sub accepting {
    set_state("accepting proxy for " . ($REMOTE || $SERVICE));
}

sub REAPER {
    my $child;
    my $start;
    while (($child = waitpid(-1, WNOHANG)) > 0) {
        if ($start = $Children{$child}) {
            my $runtime = time() - $start;
            printf "Child $child ran %dm%ss\n",$runtime / 60, $runtime % 60;
            delete $Children{$child};
        } else {
            print "Bizarre kid $child exited $?\n";
        }
    }
    
    $SIG{CHLD} = \&REAPER;    
}


