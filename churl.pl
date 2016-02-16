#!/bin/perl -w
# churl - check urls
use HTML::LinkExtor;
use LWP::Simple;

$base_url = shift or die "usage: $0 <start_url>\n";
$parser = HTML::LinkExtor->new(undef, $base_url);
$html = get($base_url);
die "Can't fetch $base_url" unless defined($html);
$parser->parse($html);
@links = $parser->link;
print "$base_url: \n";
foreach $linkarray (@links) {
    my @element = @$linkarray;
    my $elt_type = shift @element;
    while (@element) {
        my ($attr_name, $attr_value) = splice(@element, 0, 2);
        if ($attr_value->scheme =~ /\b(ftp|https?|file)\b/) {
            print "  $attr_value: ", head($attr_value) ? "OK" : "BAD", "\n";
        }
    }    
}