# filter_length.pl
# ----------------------------------------
# This script reads a FASTA file and stores
# the IDs of the sequences with the specified
# length (bp) in an ouput file.

use strict;

my ($filename, $minlength) = @ARGV;
my ($currSeq, $seqID, $seqHeader, $line, $count, $length);

$count=0;
$length=0;

open (INFILE, $filename) or die "Cannot open sequence file!\n$!\n\n";
open (IDSLIST, ">$filename.min$minlength.ids") or die "Cannot open IDs output file!\n$!\n\n";
open (OUTPUT, ">$filename.min$minlength.cds") or die "Cannot open sequence output file!\n$!\n\n";

while($line=<INFILE>){
    if($line =~ m/>/){
	if($length*3>=$minlength){
	    $count++;
	    print IDSLIST "$seqID\n";
	    print OUTPUT "$seqHeader".$currSeq."\n";
	    print "$seqID\t".($length*3)."\n";
	}
	$currSeq="";
	$seqHeader = $line;
	$line =~ m/(comp[^l].*?)[\s:]/; #[^l] is to filter out "complete" in headers
	$seqID = $1;
	$line =~ m/len:(\d*)/;
	$length = $1;
    }
    elsif($length*3>=$minlength){$currSeq .= $line;}
}

print "\n$count Sequences found.\n\nDone!\n\n";
