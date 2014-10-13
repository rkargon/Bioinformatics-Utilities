use strict;

my $infile = $ARGV[0];
my $outfile = ">$infile.assembly_stats";
open INFILE, $infile or die "Can't open input file!\n$!\n";

my ($num_transcripts, @gc_content_array, @length_array);
my ($line, @line_temp, $mean, $median);
$num_transcripts = 0;
my ($mean_gc, $mean_length) = (0,0);
my ($sum_gc, $sum_length, $sum_squares_gc, $sum_squares_length) = (0,0,0,0);
my $weighted_sum_gc = 0;
my $weighted_mean_gc;
my ($stddev_length, $stddev_gc);

print "Reading transcripts...\n";
while(chomp($line=<INFILE>)){
	if($line =~ m/Sequence/){next;}
	@line_temp = split("\t", $line);
	push(@length_array, $line_temp[1]);	
	push(@gc_content_array, $line_temp[2]);	

	#update sum and sum of squares 
	$sum_length += $line_temp[1];
	$sum_squares_length += ($line_temp[1]*$line_temp[1]);
	$sum_gc += $line_temp[2];
	$sum_squares_gc += ($line_temp[2]*$line_temp[2]);
	
	#update weighted sum
	$weighted_sum_gc += ($line_temp[1]*$line_temp[2]);
	
	$num_transcripts++;
	
	unless($num_transcripts%10000){print $num_transcripts."\n";}
}


print "\n$num_transcripts transcripts found. Sorting arrays...\n";
@gc_content_array = sort {$a <=> $b} @gc_content_array;
@length_array = sort {$a <=> $b} @length_array;
print "Done sorting.\n\n";

print "Writing to file...\n";
open OUTFILE, $outfile or die "Can't open output file!\n$!\n";
print "Transcripts found:\t$num_transcripts\n";
print OUTFILE "Transcripts found:\t$num_transcripts\n";

#length stats
print "Minimum length:\t$length_array[0]\n";
print OUTFILE "Minimum length:\t$length_array[0]\n";

if(scalar(@length_array)%2){$median = $length_array[(scalar(@length_array)-1)/2];}
else{$median = ($length_array[scalar(@length_array)/2] + $length_array[(scalar(@length_array)/2)-1])/2;}
print "Median length:\t$median\n";
print OUTFILE "Median length:\t$median\n";

$mean_length = $sum_length/$num_transcripts;
print "Mean length:\t$mean_length\n";
print OUTFILE "Mean length:\t$mean_length\n";

print "Maximum length:\t$length_array[scalar(@length_array)-1]\n";
print OUTFILE "Maximum length:\t$length_array[scalar(@length_array)-1]\n";

#A method for computing std. deviation with only keeping track of the number of elements, the sum of the elements, and the sum of their squares. 
$stddev_length = sqrt(($num_transcripts*$sum_squares_length - $sum_length*$sum_length)/($num_transcripts * ($num_transcripts-1)));
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

$mean_gc = $sum_gc/$num_transcripts;
print "Mean GC content:\t$mean_gc\n";
print OUTFILE "Mean GC content:\t$mean_gc\n";

$weighted_mean_gc = $weighted_sum_gc/$sum_length;
print "Weighted Mean GC Content:\t$weighted_mean_gc\n";
print OUTFILE "Weighted Mean GC Content:\t$weighted_mean_gc\n";

print "Maximum GC content:\t$gc_content_array[scalar(@gc_content_array)-1]\n";
print OUTFILE "Maximum GC content:\t$gc_content_array[scalar(@gc_content_array)-1]\n";

#A method for computing std. deviation with only keeping track of the number of elements, the sum of the elements, and the sum of their squares. 
$stddev_gc = sqrt(($num_transcripts*$sum_squares_gc - $sum_gc*$sum_gc)/($num_transcripts * ($num_transcripts-1)));
print "Standard Deviation of GC Content:\t$stddev_gc\n";
print OUTFILE "Standard Deviation of GC Content:\t$stddev_gc\n";

print "\n\nDone!";
