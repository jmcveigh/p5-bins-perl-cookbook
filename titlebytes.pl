#!/bin/perl -w
# titlebytes - find the title and size of documents
use strict;
use LWP::UserAgent;
use HTTP::Response;
use URI::Heuristic;

my $raw_url = shift or die "usage: $0 url\n";
my $url = URI::Heuristic::uf_urlstr($raw_url);
$| = 1;
printf "%s =>\n\t", $url;

my $ua = LWP::UserAgent->new();
$ua->agent("Schmozilla/v9.14 Platinum");

my $response = $ua->get($url, Referer => "http://wizard.yellowbrick.oz");

if ($response->is_error()) {
    printf " %s\n", $response->status_line;
} else {
    my $content = $response->content();
    my $bytes = ($content =~ tr/\n/\n/);
    my $count = ($content =~ tr/\n/\n/);
    printf("%s (%d lines, %d bytes)\n",$response->title() || "(no title)", $count, $bytes);
}
