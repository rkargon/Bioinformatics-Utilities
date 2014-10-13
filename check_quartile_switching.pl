#uses output of uclust_correlation.pl script
#assumes input is sorted by fpkm value 

use strict;
use Data::Dumper;

my @files = @ARGV;
my @samples;
my @sample_hashes;
my %flips_hash;
my %flips_histogram;
my $line;
my $cluster_num;


#loads clusters in each file into array
foreach my $filename (@files){
	open INFILE, $filename or die "$!";
	
	my @clusters; #tmp hash for storing clusters
	
	<INFILE>; #skip header line
	while(chomp($line=<INFILE>)){
		$cluster_num = (split "\t", $line)[0];
		push(@clusters, $cluster_num);
	}
	
	push @samples, \@clusters;
	close INFILE;
}


#assign quartile number to each cluster
foreach my $tmp (@samples){
	my %cluster_hash;
	
	#indices of each quartile, inclusive (so first quartile is (0 .. $q1)
	my $count = $#$tmp+1;
	my $q1 = int($count/4)-1;
	my $q2 = int($count/2)-1;
	my $q3 = int($count - $count/4)-1;
	
	
	for(0 .. $#$tmp){
		if($_ <= $q1){
			$cluster_hash{@$tmp[$_]}=1;
		}
		elsif($_ <= $q2){
			$cluster_hash{@$tmp[$_]}=2;
		}
		elsif($_ <= $q3){
			$cluster_hash{@$tmp[$_]}=3;
		}
		else{
			$cluster_hash{@$tmp[$_]}=4;
		}
	}
	
	push @sample_hashes, \%cluster_hash;
}

print "Found ".scalar (keys $sample_hashes[-1])." clusters in last file, using these.\n";

#uses clusters in last file (should have the most clusters)
foreach my $cluster (keys $sample_hashes[-1]){
	my $quartile_num=0;
	
	print $cluster."\t";
	
	for(0 .. $#sample_hashes-1){
		
		#get quartile number for this sample, only if cluster is present in this sample
		if($sample_hashes[$_]->{$cluster}) {$quartile_num = $sample_hashes[$_]->{$cluster};}
		
		#if the quartile of a certain cluster changes, add it to %flips_hash
		if($sample_hashes[$_+1]->{$cluster} and $quartile_num and ($quartile_num != $sample_hashes[$_+1]->{$cluster})){
			$flips_hash{$cluster}++;
		}
		
		
		unless ($sample_hashes[$_]->{$cluster}) {print "0\t";}
		else {print $sample_hashes[$_]->{$cluster}."\t";}
	}
	
	print ($sample_hashes[-1]->{$cluster} ? $sample_hashes[-1]->{$cluster} : 0) ."\t";
	if($flips_hash{$cluster}) {print "\tFLIP ".$flips_hash{$cluster}."\n";}
	else {print "\n";}
} 

print scalar(keys %flips_hash) . " clusters flipped quartiles.\n";
print "Number of flips:\tFrequency:\n";

foreach (values %flips_hash){
	$flips_histogram{$_}++;
}

foreach (sort keys %flips_histogram){
	print $_."\t".$flips_histogram{$_}."\n";
}

#print Dumper(%flips_hash);

print "\n\nDone!\n\n";