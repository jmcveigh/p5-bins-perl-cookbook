#!/bin/perl -w
# hrefsub - make substitutions in <A HREF="..."> fields of HTML fioles
# from Gisle Aas (gisle@aas.no>

sub usage { die "Usage: $0 <from> <to> <file>...\n" }

my $from = shift or usage;
my $to = shift or usage;
usage unless @ARGV;

# The HTML::Filter subclass to do the substitution

package MyFilter;

use HTML::Filter;

@ISA = qw(HTML::Filter);

sub start {
    my ($self, $tag, $attr, $attrseq, $orig) = @_;
    
    if ($tag eq 'a' && exists $attr->{href}) {
        # must reconstruct the start tag based on $tag and attr
        # wish we instead were told the extent of the 'href' value
        # in $orig
        my $tmp = "<$tag";
        
        for (@$attrseq) {
            my $encoded = encode_entities($attr->{$_});
            $tmp .= qq($_ = "$encoded");
        }
        $tmp .= ">";
        $self->output($tmp);
        return;
    }
    
    $self->output($orig);
}

# Now use the class.

package main;
foreach(@ARGV) {
    MyFilter->new->parse_file($_);
}