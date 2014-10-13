# random_subsample.pl
# usage: perl random_subsample.pl <ratio> <input file>
# --------------------------------------------------
# Receives a FASTA file of sequences and a ratio as input,
# and creates a FASTA file randomly selected sequences, based
# on the given ratio.

use strict;

my ($ratio, $input_filename) = @ARGV;
unless($ratio>0 and $ratio<=1.1){die "Ratio argument should be a number between 0 and 1.1.\n";} #1.1 is allowed so one can subsample ALL sequences
open INFILE, $input_filename or die "Could not open input file.\n$!\n";
open OUTFILE, ">$input_filename.subsample" or die "Could not open output file.\n$!\n";

my ($line, $isChosen);
my ($total, $out) = (0, 0);

while ($line=<INFILE>){
    if($line =~ m/>/){
	$total++;
	if(rand()<$ratio){
	    $isChosen=1;
	    $out++;
	}
	else{$isChosen=0;}
    }
    if($isChosen){print OUTFILE $line;}
}

print "total sequences read:\t$total\n";
print "sequences outputted:\t$out\n";
print "\n\nDone!";
