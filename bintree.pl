#!/bin/perl -w
# bintree - binary tree demo program
use strict;

my ($root, $n);

while ($n++ < 20) {
    insert($root, int(rand(1000)));
}

print "Pre order: "; pre_order($root); print "\n";
print "In order: "; in_order($root); print "\n";
print "Post order: "; post_order($root); print "\n";

for (print "Search? "; <>; print "Search? ") {
    chomp;
    my $found = search($root, $_);
    if ($found) {
        print "Found $_ at $found, $found->{VALUE}\n";
    } else {
        print "No $_ in tree\n";
    }    
}

exit;

sub insert {
    my ($tree, $value) = @_;
    unless ($tree) {
        $tree = {};
        $tree->{VALUE} = $value;
        $tree->{LEFT} = undef;
        $tree->{RIGHT} = undef;
        $_[0] = $tree;
        return;
    }
    
    if ($tree->{VALUE} > $value) {
        insert($tree->{LEFT}, $value);
    } elsif ($tree->{VALUE} < $value) {
        insert($tree->{RIGHT}, $value);
    } else {
        warn "dup insert of $value\n";
    }    
}

sub in_order {
    my ($tree) = @_;
    return unless $tree;
    in_order($tree->{LEFT});
    print $tree->{VALUE}, " ";
    in_order($tree->{RIGHT});
}

sub pre_order {
    my ($tree) = @_;
    return unless $tree;
    print $tree->{VALUE}, " ";
    pre_order($tree->{LEFT});
    pre_order($tree->{RIGHT});
}

sub post_order {
    my ($tree) = @_;
    return unless $tree;
    post_order($tree->{LEFT});
    post_order($tree->{RIGHT});
    print $tree->{VALUE}, " ";
}

sub search {
    my ($tree, $value) = @_;
    return unless $tree;
    if ($tree->{VALUE} == $value) {
        return $tree;
    }
    
    search($tree->{ ($value < $tree->{VALUE}) ? "LEFT" : "RIGHT"}, $value);
}