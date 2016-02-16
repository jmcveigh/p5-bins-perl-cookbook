#!/bin/perl
# cache_line_index - index style
# build_index and line_with_index from above

# usage: build_index(*DATA_HANDLE, *INDEX_HANDLE)
sub build_index {
    my $data_file = shift;
    my $index_file = shift;
    my $offset = 0;
    
    while (<$data_file>) {
        print $index_file pack("N", $offset);
        $offset = tell($data_file);
    }
}

# usage: line_with_index(*DATA_HANDLE, *INDEX_HANDLE, $LINE_NUMBER)
# returns line or undef if LINE_NUMBER was out of range
sub line_with_index {
    my $data_file = shift;
    my $index_file = shift;
    my $line_number = shift;
    my $size;
    my $i_offset;
    my $entry;
    my $d_offset;
    $size = length(pack("N", 0));
    $i_offset = $size * ($line_number - 1);
    seek($index_file, $i_offset, 0) or return;
    read($index_file, $entry, $size);
    $d_offset = unpack("N", $entry);
    seek($data_file, $d_offset, 0);
    return scalar(<$data_file>);
}

@ARGV == 2 or die "usage: print_line FILENAME LINE_NUMBER";

($filename, $line_number) = @ARGV;
open(my $orig, "<", $filename) or die "Can't open $filename for reading: $!";

$indexname = "$filename.index";
sysopen(my $idx, $indexname, O_CREAT|O_RDWR) or die "Can't open $indexname for read/write: $!";
build_index($orig, $idx) if -z $indexname;
$line = line_with_index($orig, $idx, $line_number);
die "Didn't find line $line_number in $filename" unless defined $line;
print $line;


