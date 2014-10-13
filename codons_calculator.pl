# codons_calculator.pl
# --------------------------------------------------
# Analyzes codon distributions of sequences in FASTA
# file.

use strict;
use Data::Dumper;

#open file
my $usage = "Usage: $0 <fastaFile>\n";
my $filename = $ARGV[0] or die "$usage\n\n";
print "\nOpening file\n";
open (INFILE, $filename) or die "I can't let you do that, Dave.\n$!";

#declare other vars
my (@arr, $line);
my (%codons, $codonName, $codonKey);
my (@currSeq, @currCodon);
my ($seqnum, @seqs, @seqNames);
$seqnum = 0;
my $i=1;
#my $nucleotides = ("A", "C", "G", "T");

#set up codon hash
%codons = %{InitHash(\%codons)};

#for each line in file
print "Reading sequences\n";
while (<INFILE>){
    chomp ($line=$_);

    #if current line is a seq header
    if ($_ =~ m/^>/){

	#extract sequence name
	@arr = split(/\s/, $line);
	$seqNames[$seqnum] = substr($arr[0], 1);

	#set up vars for next sequence
	$seqs[$seqnum] = "";
	$seqnum++;

	#shows progress of script
	print ".";
	unless($seqnum%100){print"\n$seqnum:";}

	next;
    }

    $seqs[$seqnum-1] .= $line;
    
}

#opens output file
open (OUTFILE, ">$filename.codonCount") or die "I can't let you do that, Dave.\n$!";;

print OUTFILE "Sequence\tAAA\tAAC\tAAG\tAAT\tACA\tACC\tACG\tACT\tAGA\tAGC\tAGG\tAGT\tATA\tATC\tATG\tATT\tCAA\tCAC\tCAG\tCAT\tCCA\tCCC\tCCG\tCCT\tCGA\tCGC\tCGG\tCGT\tCTA\tCTC\tCTG\tCTT\tGAA\tGAC\tGAG\tGAT\tGCA\tGCC\tGCG\tGCT\tGGA\tGGC\tGGG\tGGT\tGTA\tGTC\tGTG\tGTT\tTAA\tTAC\tTAG\tTAT\tTCA\tTCC\tTCG\tTCT\tTGA\tTGC\tTGG\tTGT\tTTA\tTTC\tTTG\tTTT\n";

print "\nCounting codons\n";

#for each sequence
for($i=0; $i<scalar(@seqs); $i++){
    @currSeq = split('', $seqs[$i]);
    
    while(scalar(@currSeq)>=3){
	for(1 .. 3){
	    push(@currCodon, shift(@currSeq));
	}
	
	$codonName=uc(join('', @currCodon));
	$codons{$codonName}++; 
    
	@currCodon=();
	 
    }
     
    print OUTFILE $seqNames[$i] . "\t";
    
    foreach $codonKey (sort (keys (%codons))){
	printf(OUTFILE "%d\t", $codons{$codonKey});
    }
    print OUTFILE "\n";
    %codons = %{InitHash(\%codons)};

    #shows progress of script
    print ".";
    unless(($i+1)%100){print "\n$i:";}

}
print "\n\nDone!";

sub InitHash
{
    my %codons = %{$_[0]};
    my ($i, $j, $k, @acgt);
    @acgt = ("A", "C", "G", "T");
    
    for ($i=0; $i<=3; $i++){
	for ($j=0; $j<=3; $j++){
	    for ($k=0; $k<=3; $k++){
		$codons{$acgt[$i].$acgt[$j].$acgt[$k]}=0; #sets every possible codon to 0
	    }
	}
    }
    
    return \%codons;
}
