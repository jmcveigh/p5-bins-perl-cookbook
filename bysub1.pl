#!/bin/perl
# bysub1 - simple sort by subject

my (@msgs, @sub);
my $msgno = -1;
$/ = '';
while (<>) {
    if (/^From/m) {
        /^Subject:\s*(?:Re:\s*)*(.*)/mi;
        $sub[++$msgno] = lc($1) || '';
    }
    $msgs[$msgno] .= $_;
}

for my $i (sort { $sub[$a] cmp $sub[$b] || $a <=> $b } (0 .. $#msgs )) {
    print $msgs[$i];
}