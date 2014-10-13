# filter_orfs_by_gene.pl
# ----------------------------------------
# Usage: perl filter_orfs_by_gene.pl <INPUT FASTA FILE> <HEADER LABEL>
# 
# This script reads a fasta file of transdecoder output 
# containing a set of ORFs. It then finds the longest ORF 
# present in each trinity "gene" component, or compX_cY number.
#
# It takes each of those ORFs (1 ORF per gene) and outputs them
# in a fasta file, with an optional label in the header. This can be
# used to concatenate multiple samples into one file.
#
# The script is somewhat high in memory usage, since it stores one sequence for each gene in the file until the file is completely read. 

use strict;
use Data::Dumper;

my ($infile, $label) = @ARGV;
open INFILE, $infile or die "Can't open input file!\n$!\n";
open OUTFILE, ">$infile.$label.genefiltered.cds" or die "Can't open output file!\n$!\n";

my (%seqs_hash, %lengths_hash); #the keys for these hashes are the ORF's compX_cY value
my ($line, $length, $seq, $comp_id);

while($line = <INFILE>){
    if($line =~ m/^>/){
	if($seq){ #if this isn't the first header, ie a sequence has already been read
	    if($length > $lengths_hash{$comp_id}){ #if this is longest ORF in gene so far, replace previous entry in the hash with this one
		$seqs_hash{$comp_id} = $seq;
		$lengths_hash{$comp_id} = $length;
	    } 
	}

	$seq = "> ".$label." ".substr($line, 1);
	$line =~ m/len:(\d*)/;
	$length = $1*3;
	
	$line =~ m/(comp\d*_c\d*)/;
	$comp_id = $1;
    }
    
    else {$seq .= $line;}
}

foreach my $id (sort {$lengths_hash{$b} <=> $lengths_hash{$a}} keys %lengths_hash){
    print OUTFILE $seqs_hash{$id};
}
print OUTFILE "\n";

#print Dumper(%lengths_hash);

print "\n\nDone!\n\n";

