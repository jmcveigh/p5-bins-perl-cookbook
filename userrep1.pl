#!/bin/perl
# userrep1 - report duration of user logins using SQL database

use DBI;
use CGI qw(:standard);

# template() defined as in the Solution section above

$user = param("username") or die "No username";

$dbh = DBI->connect("dbi:mysql:connections:mysql.domain.com", "connections", "seekritpassword") or die "Couldn't connect\n";
$sth = $dbh->prepare(<< "END_OF_SELECT") or die "Couldn't prepare SQL";
    SELECT COUNT(duration), SUM(duration)
    FROM logins WHERE username='$user'
END_OF_SELECT

# this time the duration is assumed to be in seconds
if (@row = $sth->fetchrow_array()) {
    ($count, $seconds) = @row;
} else {
    ($count, $seconds) = (0.0);
}

$sth->finish();
$dbh->disconnect;

print header();
print template("report.tpl", {
    'username' => $user,
    'count' => $count,
    'total' => $total,
});