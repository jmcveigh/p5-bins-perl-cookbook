#!/bin/perl -w
# chatserver - very simple chat server
use IO::Multiplex;
use IO::Socket;

use strict;

my %Name;
my $Server = IO::Socket::INET->new(LocalAddr => "localhost: 6901", Listen => 10, Reuse => 1, Proto => 'tcp') or die $@;
my $Mux = IO::Multiplex->new();
my $Person_Counter = 1;
$Mux->listen($Server);
$Mux->set_callback_object(__PACKAGE__);
$Mux->loop();
exit;

sub mux_connection {
    my ($package, $mux, $fh) = @_;
    $Name{$fh} = [ $fh, "Person " . $Person_Counter++ ];
}

sub mux_eof {
    my ($package, $mux, $fh) = @_;
    delete $Name{$fh};
}

sub mux_input {
    my ($package, $mux, $fh, $input) = @_;
    my $line;
    my $name;
    $$input =~ s{^(.*)\n+}{} or return;
    $line = $1;
    if ($line =~ m{^/nick\s+(\S+)\s*}) {
        my $oldname = $Name{$fh};
        $Name{$fh} = [ $fh, $1 ];
        $line = "$oldname->[1] is now known as $1";
    } else {
        $line = "<$Name{$fh}[1]> $line";
    }
    
    foreach my $conn_struct (values %Name) {
        my $conn = $conn_struct->[0];
        $conn->print("$line\n");
    }
}