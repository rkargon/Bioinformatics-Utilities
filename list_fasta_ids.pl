# list_fasta_ids.pl
# ----------------------------------------
# This script reads a FASTA file and prints
# the ID of each sequence to an output file,
# <filename>.ids.

use strict;

my $filename = $ARGV[0];
my ($compID, $i);

print "Opening file...\n";
open (INFILE, $filename) or die "I can't let you do that, Dave.\n$!";

print "Opening output file ".$filename.".ids...\n";
open (OUTFILE, ">$filename.ids") or die "I can't let you do that, Dave.\n$!";
print "\n";

print "Reading IDs from source file $filename...\n";

while (<INFILE>)
{
    if($_ =~ m/>/){
	$i++;
	$_ =~ m/(comp.*?)[\s:]/;
	$compID = $1;
	print "$i:\t$1\n";
	print OUTFILE "$1\n";
    }
}

print "\n\nDone!";
