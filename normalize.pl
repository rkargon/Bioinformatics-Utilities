# normalize.pl
# Usage: "perl normalize.pl <INPUT FASTA FILE>"
#
# Takes a .fasta file with a set of RNA reads, and normalizes them, placing the output in 
#  <filename>.K<KMER_SIZE>.C<DESIRED_COVERAGE>.normalized.fa
# Reads are broken up into k-mers of $KMER_SIZE length, and the coverage of each read is 
#  measured by counting these k-mers. The median coverage of the read is calculated, and 
#  if it is greater than $DESIRED_COVERAGE, the read is discarded. 
# Error correction, in which reads with a high deviation of k-mer coverage (ie most of the 
#  read is well-covered but some parts have really low coverage, which would indicate a 
#  sequencing error) are removed, is not done in this script.
# The algorithm is a streaming one, which filters reads as it counts k-mers. This is faster, 
#  but also gives preference to earlier reads in the file, which can lead to inaccuracy, 
#  if, say, for some reason reads with a high error rate are predominantly at the start of 
#  the file. However, for most data sets, where the reads are in random order, this is not a problem.
#  Also, the median coverage is used as a criterion for removal from the output data set, 
#  instead of the mean so the algorithm does not preferentially keep reads with errors in them 
#  due to a lower average coverage. 

use strict;
use Data::Dumper;

#declare global variables
our $KMER_SIZE = 25; #change this to use a different k-mer size
our $DESIRED_COVERAGE = 30; #change this for a different desired coverage

my $filename = $ARGV[0];
my (%kmers_hash, %read_coverage);
my ($sequence, $seq_id, $next_id);
my ($kmer, $median_cov);
my $totalreads=0;
my $keptreads=0;

open my $fh, $filename or die "Can't open sequence file!\n$!\n";
open OUTFILE, ">$filename.K$KMER_SIZE.C$DESIRED_COVERAGE.normalized.fa" or die "Can't open output file!\n$!\n";
$next_id = "";

my $count;

while(($seq_id, $sequence, $next_id) = readseq($fh, $next_id)){
	$count=0;
	
	$totalreads++;
	%read_coverage = ();
	#calculate coverage for each k-mer in read.
	for(1 .. length($sequence) + 1 - $KMER_SIZE){
		$kmer = substr($sequence, $_-1, $KMER_SIZE);
        if(exists ($kmers_hash{$kmer})){
            $read_coverage{$kmer}+=$kmers_hash{$kmer};
        }
        else{$read_coverage{$kmer}++;}
        
        
        $count++;
        #print "$count\tTotal kmer $kmer count:$read_coverage{$kmer}\n";
	}
    
	$median_cov = median(values %read_coverage);
	
    #if read is low coverage, include this read
	if($median_cov < $DESIRED_COVERAGE){
		$keptreads++;
		#print OUTFILE "$seq_id\n$sequence\n";
	}
    
    print "$sequence\tmediancov:$median_cov ($keptreads/$totalreads)\n";
    
    #update hash of all kmers so far with data from this read
    foreach (keys %read_coverage){
        $kmers_hash{$_}++;
    }
}

print "Normalization Done!\n";
print "Total reads read: $totalreads\tReads kept: $keptreads\n";

#function parses a FASTA file read by read, while keeping track of the next ID in the file.
sub readseq
{
	my ($fh, $next_id) = @_;
	my ($line, $seq, $id);
	my $file_is_not_empty=0;
	$id=$next_id;
	
	while(chomp($line = <$fh>)){
		$file_is_not_empty=1;
		next if ($line =~ /^\s*$/);
		
		if($line =~ m/^>/){
			if($id){
				$next_id=$line;
				return($id, $seq, $next_id);
			}
			else{$id=$line;}
		}
		else{$seq .= $line;}
	}
	
	if($file_is_not_empty){return ($id, $seq, $next_id);}
	return;
}

#returns median of given list
sub median
{
	my @values = sort {$a <=> $b} (@_);
	my $length= scalar(@values);
	
    #print Dumper(@values);
    
	if($length%2){return $values[($length-1)/2];} #odd number of items in list
	return ($values[$length/2] + $values[($length/2) - 1])/2; #even number of items in list
}
