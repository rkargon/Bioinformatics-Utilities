#!/usr/local/bin/perl -w

# This script reads in a single or multifasta file file
#  and estimates length and %GC of each sequence

use strict;

my $usage = "Usage: $0 <fastaFile>\n";

my $infile = $ARGV[0] or die "$usage\n\n";
my $outfile = "$infile.GCout";

my $seqname;
my $seq;
my $seqlength;
my $noSeqs = 0;
my ($line, @arr);

open (INFILE, $infile) or die $!;
open (OUTFILE, ">$outfile") or die $!;
print OUTFILE "Sequence  \tLength  \tpercent GC\n";

#my $date = `date`;
#print OUTFILE "Output of GCcalculator.pl on file $infile\n";
#print OUTFILE "$date\n\n";

#read sequences
while (<INFILE>) {
    chomp ($line = $_) ;
    if ($line =~ /^>/) {
	#output current seq stats
	if($noSeqs){
	    $seqlength = length($seq);
	    print OUTFILE "$seqname\t$seqlength\t".CalculateGC($seq)."\n";
	}

	#load sequence name
	@arr = split (/\s/, $line);
	$seqname = substr($arr[0], 1);

	$noSeqs++;
	unless($noSeqs%1000){print "$noSeqs\n";}
	$seq = "";
	next;
    }
    
    $seq .= $line;
}

$seqlength = length($seq);
print OUTFILE "$seqname\t$seqlength\t".CalculateGC($seq)."\n";

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
