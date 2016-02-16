#!/bin/perl -w
# tkshufflepod - recorder =head1 sections in a pod file

use Tk;
use Tk::Pod;
use strict;

my $podfile;
my $m;
my $l;
my ($up, $down);
my @sections;
my $all_pod;

$podfile = shift || "-";

undef $/;
open(F, " < $podfile") or die "Can't open $podfile : $!\n";
$all_pod = <F>;
close(F);
@sections = split(/(?==head1)/, $all_pod);

foreach (@sections) {
    /(.*)/;
    $_ = [ $_, $1 ];
}

$m = MainWindow->new();
$l = $m->Listbox('-width' => 60)->pack('-expand' => 1, '-fill' => 'both');

foreach my $section (@sections) {
    $l->insert("end", $section->[1]);
}

$l->bind('<Any-Button>' => \&down );
$l->bind('<Any-ButtonRelease>' => \&up);

$l->bind('<Double-Button>' => \&view);

$m->bind('<q>' => sub { exit });
$m->bind('<s>' => \&save);

MainLoop;

sub down {
    my $self = shift;
    $down = $self->curselection;
}

sub up {
    my $self = shift;
    my $elt;
    
    $up = $self->curselection;
    
    return if $down == $up;
    
    $elt = $sections[$down];
    splice(@sections, $down, 1);
    splice(@sections, $up, 0, $elt);
    
    $self->delete($down);
    $self->insert($up, $sections[$up]->[1]);
}

sub save {
    my $self = shift;
    
    open(F, "> $podfile") or die "Can't open $podfile for writing: $!";
    print F map { $_->[0] } @sections;
    close F;
    
    exit;
}

sub view {
    my $self = shift;
    my $temporary = "/tmp/$$-section.pod";
    my $popup;
    
    open(F, "> $temporary") or warn("Can't open $temporary : $!\n"), return;
    print F $sections[$down]->[0];
    close(F);
    $popup = $m->Pod('-file' => $temporary);
    
    $popup->bind('<Destory>' => sub { unlink $temporary });
}