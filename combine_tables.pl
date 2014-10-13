# This script takes a set of tab-delimited text files
# with the same row headings and combined them into one
# large tab-delimited text-file.
#
# The first argument gives the directory, and subsequent
# arguments give files, or file patterns in perl regex syntax

use strict;
use Data::Dumper;

my $dir = shift(@ARGV);
my @file_patterns = @ARGV;
my $file_pattern_tmp;
my @filenames;
my (@file_handles);
my ($temp, $line, $init_file);
my (@line_arr, $secondary_line, @secondary_line_arr);

opendir DIR, $dir or die "Could not open dir: $!\n";
foreach $file_pattern_tmp (@file_patterns){
    push(@filenames, grep(/$file_pattern_tmp/i, readdir DIR));
}

@filenames = sort{lc($a) cmp lc($b)} @filenames;

print "The following files will be combined:\n";
foreach (@filenames) {print $_ . "\n";}
#print "\nContinue? (enter q to quit)\n";
#chomp(my $quitflag = <STDIN>);
#if ($quitflag eq "q"){die;}

foreach (@filenames){
    local *FILE_HANDLE;
    open FILE_HANDLE, "$dir/$_" or die "Can't open input file $_!\n$!\n";
    push (@file_handles, *FILE_HANDLE);
}

#print Dumper(@filenames);
#die;

open OUTFILE, ">$dir/$filenames[0].combined" or die "Can't open output file!\n$!\n";

print OUTFILE "File:";
foreach $temp (@filenames){print OUTFILE "\t".$temp;}
print OUTFILE "\n";

$init_file = $file_handles[0];
while(chomp($line = <$init_file>)){
    print OUTFILE $line;
    @line_arr = split("\t", $line);
    foreach (1 .. scalar(@file_handles)-1){
	$temp = $file_handles[$_];
	chomp($secondary_line = <$temp>);
	@secondary_line_arr = split("\t", $secondary_line);
	for(1 .. scalar(@secondary_line_arr)-1){print OUTFILE "\t".$secondary_line_arr[$_];}
    }
    print OUTFILE "\n";
}

print "\n\nDone!\n\n";
