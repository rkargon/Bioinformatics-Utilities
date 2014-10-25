#!/usr/local/bin/perl -w

# assembly_stats.pl <fastaFile>
# Given a FASTA file of sequences, computes various statistics about the GC content and length of each sequence.
# This includes: 
# the number of total sequences,
# the minimum, median, mean, weighted mean (by sequence length), maximum, and standard deviation of GC content,
# and the minimum, median, mean, maximum, and standard deviation of length.  
# If no sequences are found, the output file is created but not written to.


use strict;

my $usage = "Usage: $0 <fastaFile>\n";

my $infile = $ARGV[0] or die "$usage\n\n";
my $outfile = "$infile.assembly_stats";

my $seq;
my ($seqLength, $seqGC);
my (@length_array, @gc_content_array);
my ($sum_length, $sum_squares_length, $sum_gc, $sum_squares_gc, $weighted_sum_gc);
my ($median, $mean_length, $stddev_length, $mean_gc, $weighted_mean_gc, $stddev_gc);
my $noSeqs = 0; #checks if a sequence has been read yet, also keeps track of number of seqs read
my ($line, @arr);

open (INFILE, $infile) or die $!;

#read sequences
while (<INFILE>) {
    chomp ($line = $_) ;
    if ($line =~ m/^>/) {
		#output current seq stats
		if($noSeqs){
		    $seqLength = length($seq);
		    $seqGC = CalculateGC($seq);
		    
		    
			push(@length_array, $seqLength);	
			push(@gc_content_array, $seqGC);	

			#update sum and sum of squares 
			$sum_length += $seqLength;
			$sum_squares_length += ($seqLength*$seqLength);
			$sum_gc += $seqGC;
			$sum_squares_gc += ($seqGC*$seqGC);

			#update weighted sum
			$weighted_sum_gc += ($seqLength*$seqGC);
		}
	
		$noSeqs++;
		unless($noSeqs%1000){print "$noSeqs\n";}
		$seq = "";
		next;
    }
    
    $seq .= $line;
}
# for last sequence in file
$seqLength = length($seq);
$seqGC = CalculateGC($seq);


push(@length_array, $seqLength);	
push(@gc_content_array, $seqGC);	

#update sum and sum of squares 
$sum_length += $seqLength;
$sum_squares_length += ($seqLength*$seqLength);
$sum_gc += $seqGC;
$sum_squares_gc += ($seqGC*$seqGC);

#update weighted sum
$weighted_sum_gc += ($seqLength*$seqGC);

### OUTPUT ###

print "\n$noSeqs transcripts found. Sorting arrays...\n";
@gc_content_array = sort {$a <=> $b} @gc_content_array;
@length_array = sort {$a <=> $b} @length_array;
print "Done sorting.\n\n";

print "Writing to file...\n";
open (OUTFILE, ">$outfile") or die $!;
if($noSeqs==0){
	die "No sequences found. Output file opened/created, but left empty.\n";
}
print "Transcripts found:\t$noSeqs\n";
print OUTFILE "Transcripts found:\t$noSeqs\n";

#length stats
print "Minimum length:\t$length_array[0]\n";
print OUTFILE "Minimum length:\t$length_array[0]\n";

if(scalar(@length_array)%2){$median = $length_array[(scalar(@length_array)-1)/2];}
else{$median = ($length_array[scalar(@length_array)/2] + $length_array[(scalar(@length_array)/2)-1])/2;}
print "Median length:\t$median\n";
print OUTFILE "Median length:\t$median\n";

$mean_length = $sum_length/$noSeqs;
print "Mean length:\t$mean_length\n";
print OUTFILE "Mean length:\t$mean_length\n";

print "Maximum length:\t$length_array[scalar(@length_array)-1]\n";
print OUTFILE "Maximum length:\t$length_array[scalar(@length_array)-1]\n";

#A method for computing std. deviation with only keeping track of the number of elements, the sum of the elements, and the sum of their squares. 
if($noSeqs > 1){ $stddev_length = sqrt(($noSeqs*$sum_squares_length - $sum_length*$sum_length)/($noSeqs * ($noSeqs-1))); }
else{ $stddev_length = 0; }
print "Standard Deviation of Length:\t$stddev_length\n";
print OUTFILE "Standard Deviation of Length:\t$stddev_length\n";

undef @length_array; #clears out some memory.

#GC content stats
print "Minimum GC content:\t$gc_content_array[0]\n";
print OUTFILE "Minimum GC content:\t$gc_content_array[0]\n";

if(scalar(@gc_content_array)%2){$median = $gc_content_array[(scalar(@gc_content_array)-1)/2];}
else{$median = ($gc_content_array[scalar(@gc_content_array)/2] + $gc_content_array[(scalar(@gc_content_array)/2)-1])/2;}
print "Median GC content:\t$median\n";
print OUTFILE "Median GC content:\t$median\n";

$mean_gc = $sum_gc/$noSeqs;
print "Mean GC content:\t$mean_gc\n";
print OUTFILE "Mean GC content:\t$mean_gc\n";

$weighted_mean_gc = $weighted_sum_gc/$sum_length;
print "Weighted Mean GC Content:\t$weighted_mean_gc\n";
print OUTFILE "Weighted Mean GC Content:\t$weighted_mean_gc\n";

print "Maximum GC content:\t$gc_content_array[scalar(@gc_content_array)-1]\n";
print OUTFILE "Maximum GC content:\t$gc_content_array[scalar(@gc_content_array)-1]\n";

#A method for computing std. deviation with only keeping track of the number of elements, the sum of the elements, and the sum of their squares. 
if($noSeqs>1){ $stddev_gc = sqrt(($noSeqs*$sum_squares_gc - $sum_gc*$sum_gc)/($noSeqs * ($noSeqs-1))); }
else{ $stddev_gc = 0; }
print "Standard Deviation of GC Content:\t$stddev_gc\n";
print OUTFILE "Standard Deviation of GC Content:\t$stddev_gc\n";

print "DONE\n\n";

sub CalculateGC
{
    my $seq = $_[0];
    my @arr;
    my ($GC, $AT, $NN);
	
    @arr = split  (//, $seq);
	
    for (my $j = 0; $j < scalar(@arr); $j++) {
	if ( ($arr[$j] eq 'a') || ($arr[$j] eq 'A') ||
	     ($arr[$j] eq 't') || ($arr[$j] eq 'T') ) { $AT++; next; }
	elsif  ( ($arr[$j] eq 'c') || ($arr[$j] eq 'C') ||
		 ($arr[$j] eq 'g') || ($arr[$j] eq 'G') ) { $GC++; next; }  
	else { $NN++; }
    }
    return  ($GC /($AT + $GC)) * 100 ; 
}
