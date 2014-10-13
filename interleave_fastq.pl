# interleave_fastq.pl
# --------------------
# A perl script that interleaves two paired-end fastq files

use strict;
use IO::Uncompress::Gunzip;

#get left, right, and output filenames
my ($leftfile, $rightfile, $output) = @ARGV;
my ($left, $right, $out);
my ($leftline, $rightline);
my $seqs=0;


if($leftfile =~ m/\.gz$/){$left = new IO::Uncompress::Gunzip $leftfile or die "gunzip failed: $!\n";}
else {open $left, $leftfile or die "Couldn't open left fastq file:\n$!\n";}

if($rightfile =~ m/\.gz$/){$right = new IO::Uncompress::Gunzip $rightfile or die "gunzip failed: $!\n";}
else {open $right, $rightfile or die "Couldn't open right fastq file:\n$!\n";}

open $out, ">$output" or die "Couldn't open output fastq file:\n$!\n";

while (1){

    #read from first file
    $leftline = <$left>;
    unless($leftline) {last;}
    print $out $leftline;

    $leftline = <$left>;
    print $out $leftline;

    $leftline = <$left>;
    print $out $leftline;

    $leftline = <$left>;
    print $out $leftline;
    
    #read from second file
    $rightline = <$right>;
    print $out $rightline;

    $rightline = <$right>;
    print $out $rightline;

    $rightline = <$right>;
    print $out $rightline;

    $rightline = <$right>;
    print $out $rightline;

    $seqs++;
    if($seqs%1000==1){print "Seqs read from file: ".$seqs."\n";}

}

print "\n\nDone!";
