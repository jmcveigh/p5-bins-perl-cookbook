#!/bin/perl -w
# nonforker - server who multiplexes without forking
use POSIX;
use IO::Socket;
use IO::Select;
use Socket;
use Fcntl;
use Tie::RefHash;

$port = 1685; # change this at will

#listen to port
$server = IO::Socket::INET->new(
    LocalPort => $port,
    Listen => 10,
) or die "Can't make server socket: $@\n";

# begin with empty buffers
my %inbuffer = ();
my %outbuffer = ();
my %ready = ();

tie %ready, 'Tie::RefHash';

nonblock($server);
$select = IO::Select->new($server);

# main loop: check reads/accepts, check writes, check ready to process
while (1) {
    my $client;
    my $rv;
    my $data;
    
    # check for new information on the connections we have
    
    # anything to read or accept?
    foreach $client ($select->can_read(1)) {
        if ($client == $server) {
            # accept a new connection
            $client = $server->accept();
            $select->add($client);
            nonblock($client);
        } else {
            # read data
            $data = '';
            $rv = $client->recv($data, POSIX::BUFSIZ, 0);
            
            unless (defined($rv) && length $data) {
                # this would be the end of file, so close the client
                delete $inbuffer{$client};
                delete $outbuffer{$client};
                delete $ready{$client};
                
                $select->remove($client);
                close $client;
                next;
            }
            
            $inbuffer{$client} .= $data;
            
            # test whether the data in the buffer or the data we
            # just read means there is a complete request waiting
            # to be fulfilled.  If there is, set $ready{$client}
            # to the requests waiting to be fulfilled.
            while ($inbuffer{$client} =~ s/(.*\n)//) {
                push( @{$ready{$client}}, $1);
            }
        }            
    }
    
    # any com[plete requests to process?
    foreach $client (keys %ready) {
        handle($client);
    }
    
    # buffers to flush?
    foreach $client ($select->can_write(1)) {
        # skip this client if we have nothing to say
        next unless exists $outbuffer{$client};
        
        $rv = $client->send($outbuffer{$client},0);
        unless (defined $rv) {
            # whine, but move on.
            warn "I was told I could write, but I can't.\n";
            next;
        }
        
        if ($rv == length $outbuffer{$client} || $1 == POSIX::EWOULDBLOCK) {
            substr($outbuffer{$client}, 0, $rv) = '';
            delete $outbuffer{$client} unless length $outbuffer{$client};
        } else {
            # Couldn't write all the data, and it wasn't because
            # it would have blocked.  Shutdown and move on.
            delete $inbuffer{$client};
            delete $outbuffer{$client};
            delete $ready{$client};
            
            $select->remove($client);
            close($client);
            next;
        }
    }
    
    # Out of band data?
    foreach $client ($select->has_exception(0)) { # arg timeout
        # Deal with out-of-band data here, if your want to.
    }
}

# handle($socket) deals with all pending requests for $client
sub handle {
    # requests are in $ready{$client}
    # send output to $outbuffer{$client}
    my $client = shift;
    my $request;
    
    foreach $request (@{$ready{$client}}) {
        # $request is the text of the request
        # put text of reply into $outbuffer{$client}
    }
    
    delete $ready{$client};
}

# nonblock($socket) puts socket into noblocking mode
sub nonblock {
    my $socket = shift;
    my $flags;
    
    $flags = fcntl($socket, F_GETFL, 0) or die "Can't get flags for socket; $!\n";
    fcntl($socket, F_SETFL, $flags | O_NONBLOCK) or die "Can't make socket nonblocking: $!\n";
}