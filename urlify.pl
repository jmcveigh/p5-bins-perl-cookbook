#!/bin/perl
# urlify - wrap HTML links around URL-link constructs
$protos = '(http|telnet|gpher|file|wais|ftp)';
$ltrs = '\w';
$gunk = ';/#~:.?+=&%@!\-';
$punc = '.:?\-';
$any = "${ltrs}${gunk}${punc}";

while (<>) {
    s{
            \b
            (
                 $protos :
                 [$any] +?
            )
            (?=
                [$punc]*
                [^$any]
                |
                $
            )
    }{MA HREF="$1">$1</A>}igox;
    print;
}
