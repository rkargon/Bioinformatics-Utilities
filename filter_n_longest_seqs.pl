# filter_n_longest_seqs.pl
# ------------------------------
# Usage: perl filter_n_longest_seqs.pl <FASTA_FILE> <NUMBER_OF_SEQS>
# ------------------------------
# This script outputs the n longest sequences in a given fasta file into a new fasta file, 
# as well as creating a sorted list of the sequence lengths in another file.
# This script can be memory intensive as it loads the whole file into memory, so use with caution.

use strict;
use Data::Dumper;

my $usage = "# filter_n_longest_seqs.pl
# ------------------------------
# Usage: perl filter_n_longest_seqs.pl <FASTA_FILE> <NUMBER_OF_SEQS>
# ------------------------------
# This script outputs the n longest sequences in a given fasta file into a new fasta file. 
# This script can be memory intensive as it loads the whole file into memory, so use with caution.";

my ($filename, $n) = @ARGV;
if(scalar(@ARGV)<2 or $n < 1){die "\n\n$usage\n\n";}

open INFILE, $filename or die "Can't open input file!\n$!\n\n";
my ($line, $seq, $header);
my (%length_hash, %sequence_hash);
my $header_tmp;
my $i=0;

while (chomp($line=<INFILE>)){
    if($line =~ /^>/){
	if(length($seq)){
	    $sequence_hash{$header}=$seq;
	    $length_hash{$header} = length($seq);
	    $seq = "";
	}	
	$header = $line;
    }
    else{$seq .= $line;}
}

#print Dumper(%length_hash);
#print Dumper(%sequence_hash);

open OUTFILE, ">$filename.top$n.fasta" or die "Can't open output file!\n$!\n\n";
open LENGTHLIST, ">$filename.top$n.lengthlist" or die "Can't open length list output file!\n$!\n\n";

foreach $header_tmp (sort {$length_hash{$b} <=> $length_hash{$a}} keys %length_hash){
    if($i<$n){
	print OUTFILE "$header_tmp\n$sequence_hash{$header_tmp}\n";
	print  "$length_hash{$header_tmp}\n";
	print LENGTHLIST "$length_hash{$header_tmp}\n";
    }
    
    $i++;
}

print "\n\nDone!\n\n";
