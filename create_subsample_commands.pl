# create_subsample_commands.pl
# Raphael Kargon 2013
# ------------------------------
# Usage: create_subsample_commands.pl <FILE> <PATTERN>
# ------------------------------
# This script, when given a string stored in a file, 
# creates copies of that string, with <PATTERN> replaced with
# a list of other string.
# 
# Currently these strings are subsample numbers for my 
# transcriptome coverage project:
# 005, 010, 020, 030, 030_2, 030_3, 040, 050, 050_2, 050_3, 060, 070, 080, 080_2, 080_3, 090, 100
#
# For example, running this command with a file containing 
# the string "mkdir subsample_<NAME> <NAME>" will create
# the strings subsample_005, subsample_010, etc.
# 
# This is useful for creating long terminal commands for a whole set of files/samples/etc

use strict;

unless(scalar(@ARGV)){
    print "Usage: create_subsample_commands.pl <FILE> <PATTERN>\n\n";
    die;
}

my ($filename, $pattern) = @ARGV;
my ($string, $string_tmp);
my @replacements = ("005", "010", "020", "030", "030_2", "030_3", "040", "050", "050_2", "050_3", "060", "070", "080", "080_2", "080_3", "090", "100");
my $replacement;

open INFILE, $filename or die "Can't open input file!\n$!\n";
open OUTFILE, ">$filename.out" or die "Can't open output file!\n$!\n";

#load file contents
while(<INFILE>){$string .= $_;}

print "String loaded:\n$string\n\nOutput:\n";

foreach $replacement (@replacements){
    $string_tmp = $string;
    $string_tmp =~ s/$pattern/$replacement/g;
    print OUTFILE $string_tmp."\n";
    print $string_tmp."\n";
}

print "\n\nDone!\n\n";
