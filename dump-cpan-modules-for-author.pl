#!/bin/perl -w
# dump-cpan-modules-for-author - display modules a CPAN author owns
use LWP::Simple;
use URI;
use HTML::TableContentParser;
use HTML::Entities;
use strict;

our $URL = shift || 'http://search.cpan.org/author/TOMC/';
my $table = get_tables($URL);
my $modules = $tables->[4];
foreach my $r (@{ $modules->{rows}}) {
    my ($module_name, $module_link, $status, $description) = parse_module_row($r, $URL);
    print "$module_name <$module_link>\n\t$status\n\t$description\n\n";
}

sub get_tables {
    my $URL = shift;
    my $page = get($URL);
    my $tcp = new HTML::TableContentParser;
    return $tcp->parse($page);
}

sub parse_module_row {
    my ($row, $URL) = @_;
    my ($module_html, $module_link, $module_name, $status, $description);
    
    # extract cells
    
    $module_html = $row->{cells}[0]{data};
    $status = $row->{cells}[1]{data};
    $description = $row->{cells}[2]{data};
    $status =~ s{<.*?>}{}g;
    ($module_link, $module_name) = $module_html =~ m{href="(.*?)".*?>(.*)<}i;
    $module_link = URI->new_abs($module_link, $URL); #resolve relative links
    # clean up entities and tags
    decode_entites($module_name);
    decode_entities($description);
    
    return ($module_name, $module_link, $status, $description);    
}