# preview_gz.pl <line_num> <file>
# ----------------------
# A small perl script that print out 
# <line_num> lines from a .gz compressed file.

use strict;
use IO::Uncompress::Gunzip;

my ($file, $line);
my ($num_lines, $filename) = @ARGV;
$file = new IO::Uncompress::Gunzip $filename or "gunzip failed: $!\n";

for (1 .. $num_lines){
	$line = <$file>;
	print $line;
}