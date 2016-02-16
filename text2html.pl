#!/bin/perl -p00
# text2html - trivial html encoding of normal text
# -p means apply this script to each record.
# -00 mean that a record is now a paragraph

use HTML::Entities;
$_ = encode_entities($_, "\200-\377");

if (/^\s/) { 
    s{(.*)$}{<PRE>\n$1</PRE>}s;
} else {
    s{<URL:(.*?)}{<A HREF="$1">$1</A>}gs || s{(http:\S+)}{<A HREF="$1">$1</A>}gs;
    s{(\S+)*}{<STRING>$1<\/STRONG>}g;
    s{\b_(\S+)\_\b}{<EM>$1</EM>}g;
    s{^}{<P>\n};
}
