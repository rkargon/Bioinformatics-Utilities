# perl count_cluster.pl
# -------------------------------
# Takes a trinity sequence file, and counts the number of clusters found.
# Also creates a frequency distribution of the number of sequences per cluster.

use strict;
use Data::Dumper;

my $filename = $ARGV[0];
open INFILE, $filename or die "Can't open input file!\n$!\n";

my (%clusters, %cluster_frequencies);
my ($cluster_id, $sequence_number);
my ($line, $key, $number_of_clusters, $transcripts_read);
$number_of_clusters=0;
$transcripts_read=0;

#count of # of sequences in each cluster.
while (chomp($line=<INFILE>))
{
    if($line =~ m/(comp\d*_c\d*)_seq(\d*)/){
	$cluster_id=$1;
	$clusters{$cluster_id}++;
	$transcripts_read++;
	unless($transcripts_read%10000){print "Transcripts Read:\t$transcripts_read\n";}
    }
    else {next;}
}

#create histogram of # of seqs per cluster, and counts the total number of clusters
foreach $key (keys %clusters){
    $cluster_frequencies{$clusters{$key}}++;
    $number_of_clusters++;
}

open OUTFILE, ">$filename.clusterCount" or die "Can't open output file!\n$!\n";
print OUTFILE "Total Clusters:\t$number_of_clusters\n";
print "Total Clusters:\t$number_of_clusters\n";
print OUTFILE "Cluster Size\tFrequency\n";
print "Cluster Size\tFrequency\n";

foreach $key (sort{$a<=>$b} keys(%cluster_frequencies))
{
    print OUTFILE $key . "\t" . $cluster_frequencies{$key} . "\n";
    print $key . "\t" . $cluster_frequencies{$key} . "\n";
}

print "\n\nDone!\n";
