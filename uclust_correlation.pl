# perl uclust_correlation.pl <-u=UCLUST-FILE> <-s=SAMPLE-NAMES...> [-p=PRINCIPAL-SAMPLE] [-c=COLNUM] <-r=RSEM-FILES...> [-h]
# --------------------------------------------------------------------------------------------------------------------------
# 

use strict;
use Getopt::Long;
use Data::Dumper;

my $usage = "perl uclust_correlation.pl <-u=UCLUST-FILE> <-s=SAMPLE-NAMES...> [-p=PRINCIPAL-SAMPLE] [-c=COLNUM] <-r=RSEM-FILES...> [-h]
This script finds the correlation coefficient of expression values between a set of transcripts. It uses a UCLUST output file to compare genes
across samples that are clustered together. 

Command Line Arguments:
REQUIRED:
--uclust-file, -u		Specifies the uclust output file to use.

--sample-names, -s		Names of samples to be compared. Used to extract sequences from UCLUST output. Takes several inputs, separated by spaces, eg -s sample1 sample2 sample3 etc....

--rsem-files, -r		RSEM gene results files that provide expression values. Will be used matched to sample names in the order they are given. (if there are more RSEM files than
				samples, the last few RSEM files will not be used)

OPTIONAL:
--principal-sample, -p		The sample that all other samples will be compared to, pairwise, to get regression values. If it is not specified, or that sample name is not present in the
				set of specified samples, the first sample given in the -s argument will be used.
				
--colnum, -c			The column of data to read from the RSEM input files. By default, this is 6, which reads TPM data from the RSEM files.
--help, -h			Shows this help.
";

my ($uclustfile, @samplenames, $principal_sample, $colnum, @rsemfiles, $help); #command line args
$principal_sample="";
$colnum=6;
$help=0;
GetOptions('uclust-file|u=s' => \$uclustfile, 'sample-names|s=s{,}' => \@samplenames, 'principal-sample|p=s' => \$principal_sample, 'colnum|c=i' => \$colnum, 'rsem-files|r=s{,}' => \@rsemfiles, 'help|h' => \$help) or die "$!\n$usage\n";
if($help){die $usage."\n"}

=Test Command-line Arguments
print "uclust file path: $uclustfile\n";
print "sample file paths: ".Dumper(@samplenames)."\n";
if($principal_sample) {print "Principal sample: $principal_sample\n";}
else {print "No principal sample\n";}
print "Column Number: $colnum\n";
print "rsem gene result file paths: ".Dumper(@rsemfiles)."\n";
print "You ". ($help ? "" : "do not ") . "want help.\n";
die;
=cut

# Checks for valid input
unless($uclustfile and scalar(@samplenames) and scalar(@rsemfiles)){die $usage;}
unless($principal_sample){
	$principal_sample = $samplenames[0];
	print "No principal sample specified, using \"$principal_sample\"\n";
}
if(scalar(@samplenames)>scalar(@rsemfiles)){die "Not enough RSEM files specified! You are missing ".(scalar(@samplenames)-scalar(@rsemfiles))." files.\n";}
elsif(scalar(@samplenames)<scalar(@rsemfiles)){print "Too many RSEM files specified, will only use first ".scalar(@samplenames)."\n";}

my $sample_regex; #regex that matches all sample names
my %uclust_samples; #stores data from uclust file. Each sample name points to a hash of cluster numbers, each cluster number points to a hash of transcripts (since some clusters can have more than one transcript), and each transcript ID points to the transcript's length (and expression)
my %seeds; #stores longest sequence in each cluster
my %expression_values; #stores the expression values of each compX_cY. Used once for each subsample. 
my %collapsed_samples; #stores data with each cluster collapsed to one expression value. Structure is similar to %uclust_samples, except that each cluster stores an expression value instead of a hash of transcripts	
my %quartiles; #assigns a quartile to each cluster in principal sample
my ($rgxtmp, $line, @line_arr, $i, $sample_name, $comp_name, $rsem_tmp_handle, $cluster_num, $total_reads, $sample_expression, $principal_expression); #temp vars

open UCLUST, $uclustfile or die "Can't open UCLUST file!\n$!\n";

#generates regex of the form "sample1|sample2|sample3|etc", first escaping special chars.
for(0 .. scalar(@samplenames)-1){
	if($_){$sample_regex.="|";}
	$rgxtmp = $samplenames[$_];
	$rgxtmp =~ s/([$^*()+\[\]\\{}\|\"\'\/])/\\\1/g;
	$sample_regex.="".$rgxtmp;
}

### SPLIT UCLUST SAMPLES ###
print "Splitting uclust subsamples...\n";
$i=0;
while (chomp($line=<UCLUST>)){
	# match subsample name in UCLUST line
	if($line =~ m/^[HS].*?[DI*M]\s+\b($sample_regex)\b/){
		$sample_name = $1;
		@line_arr = split("\t", $line);
		
		$line =~ m/^.*?(comp\d+_c\d+)/;
		$comp_name = $1;
				
		$uclust_samples{$sample_name}{$line_arr[1]}{$comp_name}{len} = $line_arr[2];
		if($line =~ m/^S/i){ $seeds{$line_arr[1]} = {sample_name => $sample_name, compname => $comp_name, len => $line_arr[2]};}
		
		unless(++$i % 50000){print $i . "\n";}
	}
}
print $i." transcripts read, average ".$i/scalar(@samplenames)." transcripts per sample.\n\n";
close UCLUST;



### ADD RSEM DATA ###
print "Reading expression information...\n";
foreach (0 .. scalar(@rsemfiles)-1){
	%expression_values = ();
	open $rsem_tmp_handle, $rsemfiles[$_] or die "Can't open RSEM input file!\n$!\n";
	$sample_name = $samplenames[$_];

	#read rsem file for a given sample, load into %expression_values
	$i=0;
	while(chomp($line=<$rsem_tmp_handle>)){
		@line_arr = split("\t", $line);
		$expression_values{$line_arr[0]} = $line_arr[$colnum-1];
		unless(++$i % 1000){print ".";}
	}
	
	#for each cluster in the sample, check each transcript in the cluster and assign corresponding expression value
	foreach $cluster_num (keys %{$uclust_samples{$sample_name}}){
		foreach $comp_name (keys %{$uclust_samples{$sample_name}{$cluster_num}}){
			$uclust_samples{$sample_name}{$cluster_num}{$comp_name}{expression} = $expression_values{$comp_name};
		}
	}
	
	print "\n$i sequences read for ". $sample_name."\n";
	
	close $rsem_tmp_handle;
}

#print Dumper($uclust_samples{"subsample_030_2"});

### COLLAPSE CLUSTERS ###
print "\nCollapsing clusters with multiple transcripts...\n";

#for each cluster in each sample, combine the expression values if there is more than one transcript
#This form of combination works for FPKM and TPM
foreach $sample_name (sort keys %uclust_samples){
	$i=0;
	
	foreach $cluster_num (keys %{$uclust_samples{$sample_name}}){
		$total_reads = 0;
		#check if there is more than one transcript in given cluster
		if(scalar(keys %{$uclust_samples{$sample_name}{$cluster_num}})>1){
			foreach $comp_name (keys %{$uclust_samples{$sample_name}{$cluster_num}}){
				#multiplies expression by length of transcript to find the total reads mapped to that transcript, adds to total count for cluster
				$total_reads += $uclust_samples{$sample_name}{$cluster_num}{$comp_name}{len}*$uclust_samples{$sample_name}{$cluster_num}{$comp_name}{expression};
			}
			
			#stores new expression value in %collapsed_samples
			$collapsed_samples{$sample_name}{$cluster_num} = $total_reads / $seeds{$cluster_num}{len};
		}
		else {
			#get expression value of the only comp# in the cluster
			foreach $comp_name (keys %{$uclust_samples{$sample_name}{$cluster_num}}){
				$collapsed_samples{$sample_name}{$cluster_num} = $uclust_samples{$sample_name}{$cluster_num}{$comp_name}{expression};
			}
		}
		unless(++$i % 1000){print ".";}
	}
	
	print "\n$i clusters processed for ". $sample_name."\n";
}

print "\n";

### OUTPUT PAIRED CLUSTERS ###


#indices of each quartile, inclusive (so first quartile is (0 .. $q1)
my $count = (scalar keys %{$collapsed_samples{$principal_sample}});
my $q1 = int($count/4);
my $q2 = int($count/2);
my $q3 = int($count - $count/4);

print "First Quartile:\t$q1\n";
print "Second Quartile:\t$q2\n";
print "Third Quartile:\t$q3\n";
print "Total Count:\t$count\n";

#assign quartile values based on expression in principal sample
$i=1;
foreach $cluster_num (sort {$collapsed_samples{$principal_sample}{$a} <=> $collapsed_samples{$principal_sample}{$b}} keys %{$collapsed_samples{$principal_sample}}){
	if($i <= $q1){
		$quartiles{$cluster_num}=1;
	}
	elsif($i <= $q2){
		$quartiles{$cluster_num}=2;
	}
	elsif($i <= $q3){
		$quartiles{$cluster_num}=3;
	}
	else{
		$quartiles{$cluster_num}=4;
	}
	$i++;	
}

foreach $sample_name (sort keys %collapsed_samples){

	my (@handles);
	
	for(1 .. 4){
		local *FILE;
		open FILE, ">uclust.q".$_.".$sample_name.$principal_sample.compared" or die "Can't open output file!\n$!\n";
		print FILE "Cluster\t$principal_sample\t$sample_name\n";
		push (@handles, *FILE);
	}
	#file with all quartiles
	open ALL_OUT, ">uclust.all.$sample_name.$principal_sample.compared" or die "Can't open output file!\n$!\n";
	print ALL_OUT "Cluster\t$principal_sample\t$sample_name\n";
	
	print "$sample_name has ".scalar(keys %{$collapsed_samples{$sample_name}})." clusters.\n";
	#for each cluster in current sample
	$i=0;
	foreach $cluster_num (sort {$collapsed_samples{$principal_sample}{$a} <=> $collapsed_samples{$principal_sample}{$b}} keys %{$collapsed_samples{$principal_sample}}){
		$sample_expression = $collapsed_samples{$sample_name}{$cluster_num};
		$principal_expression = $collapsed_samples{$principal_sample}{$cluster_num};
			
		if($collapsed_samples{$principal_sample}{$cluster_num}){
			if($sample_expression>0 and $principal_expression>0){
			#print $principal_expression."\n";
			#if($sample_expression>0.01*$principal_expression and $sample_expression<100*$principal_expression){
				print {$handles[$quartiles{$cluster_num}-1]} ($cluster_num . "\t" . $principal_expression . "\t" . $sample_expression . "\n");
				print ALL_OUT ($cluster_num . "\t" . $principal_expression . "\t" . $sample_expression . "\n");
				$i++;
			#}
			}
		}
	}
	print $i . " 	clusters outputted.\n";
}


print "\n\nDone!\n\n";