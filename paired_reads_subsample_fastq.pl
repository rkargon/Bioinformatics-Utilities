# paired_reads_subsample_fastq.pl <ratio> <filename>
# --------------------------------------------------
# A perl script that randomly subsamples a paired-end fastq file,
# taking into account paired-end reads

use strict;

my ($ratio, $filename, $outfilename) = @ARGV;
if($outfilename){$outfilename = ">$outfilename";}
else{$outfilename = ">$filename.$ratio.subsample.fastq";}
open INFILE, $filename or die "can't open input file!: $!\n";
open OUTFILE, $outfilename or die "can't open output file!: $!\n";
unless($ratio>0 and $ratio<=1.1){die "Ratio argument should be a number between 0 and 1.1.\n";} #1.1 is allowed so one can subsample ALL sequences

my ($line, $isChosen);
my ($total, $out) = (0, 0);

while($line = <INFILE>){
	for (1 .. 7){$line .= <INFILE>;}
	$total++;
	if(rand()<$ratio){
	    $isChosen=1;
	    $out++;
	}
	else{$isChosen=0;}
    if($isChosen){print OUTFILE $line;}
}

print "\nFilename: $outfilename\n";
print "Total sequences read:\t$total\n";
print "Sequences outputted:\t$out\n";