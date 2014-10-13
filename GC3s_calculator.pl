# GC3s_count.pl
# Usage: perl GC3s_calculator.pl <codon_usage_table>
# ------------------------------------------------------------------
# This script reads a tab-delimited file that contains the 
# codon usage frequencies for a set of sequences. Then the GC  content of 
# the nucleotides at the third codon position (excluding methionine 
# and triptophan) is calculated for each sequence and is outputted in a 
# tab-delimited file. 
# 
# ------------------------------------------------------------------
# NOTE: This script works best with output from codons_calculator.pl

use strict;

my $filename = $ARGV[0];
my ($header, @headerArr, @GC3_indices);
my ($line, @lineArr);
my ($GC_count, $total_count, $seqID);
my $i=0;

open INFILE, $filename or die "Can't open input file.\n$!\n";
open OUTFILE, ">$filename.GC3s_no_met_trp" or die "Can't open output file.\n$!\n";
print OUTFILE "Sequence\tGC3%\n";

#parse header
chomp($header = <INFILE>);
@headerArr=split('\t', $header); 

#load indices of GC3 codons in the data file
for (0 .. scalar(@headerArr)-1){
	if($headerArr[$_] =~ m/[actgu][actgu][cg]/i and ($headerArr[$_] ne "ATG" and $headerArr[$_] ne "TGG")){
		push(@GC3_indices, $_);
	}
}

while (chomp($line=<INFILE>)){
	$GC_count = 0;
	$total_count=0; 
	
	@lineArr=split('\t', $line);
	$seqID = @lineArr[0];
	
	foreach (@GC3_indices){$GC_count+=$lineArr[$_];}
	for (1 .. scalar(@lineArr-1)){$total_count+=$lineArr[$_];}
	
	print OUTFILE "$seqID\t".100*$GC_count/$total_count."\n";
	$i++;
	print ".";
	unless($i%4000){print"\n$i: ";}
}

print "\n\nDone!";
