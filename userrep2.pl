#!/bin/perl -w
# userrep2 - report duration of user logins using SQL database

use Text::Template;
use DBI;
use CGI qw(:standard);

$tmpl = "/home/httpd/templates/fancy.template";
$template = Text::Template->new(-type => "file", -source => $tmpl);
$user = param("username") or die "No username";

$dbh = DBI->connect("dbi:mysql:connections:mysql.domain.com", "connections", "secret passwd") or die "Couldn't db connect\n";
$sth = $dbh->prepare(<< "END_OF_SELECT") or die "Couldn't prepare SQL";
    SELECT COUNT(duration), SUM(duration)
    FROM logins WHERE username='$user'
END_OF_SELECT

$sth->execute() or die "Couldn't execute SQL";

if (@row = $sth->fetchrow_array()) {
    ($count, $total) = @row;
} else {
    $count = $total = 0;
}

$sth->finish();
$dbh->disconnect();

print header();
print $template->fill_in();