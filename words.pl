#!/bin/perl -w
# words - gather lines, present in columns

use strict;

my ($item, $cols, $rows, $maxlen);
my ($xpixel, $ypixel, $mask, @data);

getwinsize();

# first gather every line of input,
# remembering the longest line length seen
$maxlen = 1;
while (<>) {
    my $mylen;
    s/\s+$//;
    $maxlen = $mylen if (($mylen = length) > $maxlen);
    push(@data, $_);
}

$maxlen += 1; # to make extra space

# determine boundaries of screen
$cols = int($cols / $maxlen) || 1;
$rows = int(($#data + $cols) / $cols);

# pre-create mask for faster computation
$mask = sprintf("%%-%ds ", $maxlen - 1);

# subroutine to check whether at last item online
sub EOL { ($item + 1) % $cols == 0 }

# now process each item, picking out proper piece for this position
for ($item = 0; $item < $rows * $cols; $item++) {
    my $target = ($item % $cols) * $rows + int ($item / $cols);
    my $piece = sprintf($mask, $target < @data ? $data[$target] : "");
    $piece =~ s/\s+$// if EOL(); # don't blank-pad to EOL
    print $piece;
    print "\n" if EOL();
}

# finish up if needed
print "\n" if EOL();

# not portable -- linux only
sub getwinsize {
    my $winsize = "\0" x 8;
    my $TIOCGWINSZ = 0x40087468;
    if (ioctl(STDOUT, $TIOCGWINSZ, $winsize)) {
        ($rows, $cols, $xpixel, $ypixel) = unpack('$4', $winsize);
    } else {
        $cols = 80;
    }
}
