#!/bin/perl -w
# htmlsub - make substitions in normal text of HTML files
# from Gisle Aas <gisle@aas.no>

sub usage { die "Usage: $0 <from> <to> <files>...\n" }

my $from = shift or usage;
my $to = shift or usage;

usage unless @ARGV;

# Build the HTML::Filter subclass to do the substituting

package MyFilter;
use HTML::Filter;
@ISA = qw(HTML::Filter);
use HTML::Entities qw(decode_entities encode_entities);

sub text {
    my $self = shift;
    my $text = decode_entites($_[0]);
    $text =~ s/\Q$from/$to/go; # most important line
    $self->SUPER::text(encode_entities($text));
}

# Now use the class.

package main;

foreach (@ARGV) {
    MyFilter->new->parse_file($_);
}