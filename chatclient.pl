#!/bin/perl -w
# chatclient - client for the chat server
use IO::Multiplex;
use IO::Socket;
use strict;

my $sock = IO::Socket::INET->new(PeerAddr => "localhost:6901", Proto => "tcp") or die $@;
my $Mux = IO::Multiplex->new();
$Mux->add($sock);
$Mux->add(*STDIN);
$Mux->set_callback_object(__PACKAGE__);
$Mux->loop();
exit;

sub mux_input {
    my ($package, $mux, $fh, $input) = @_;
    my $line;
    $line = $$input;
    $$input = "";
    if (fileno($fh) == fileno(STDIN)) {
        print $sock $line;
    } else {
        print $line;
    }    
}