# separate_fastq.pl
# --------------------
# A perl script that separates an intereleaved paired-end fastq file

use strict;

my $input = @ARGV[0];
my ($line, $seqnum);
open INPUT, $input or die "Can't open input file!\n$!";
open R1, ">$input.R1.fastq" or die "Can't open R1 output file!\n$!";
open R2, ">$input.R2.fastq" or die "Can't open R2 output file!\n$!";

$seqnum=0;
while (1){
    $line = <INPUT>;
    unless($line){last;}
    $line .= <INPUT>;
    $line .= <INPUT>;
    $line .= <INPUT>;
    print R1 $line;

    $line = <INPUT>;
    $line .= <INPUT>;
    $line .= <INPUT>;
    $line .= <INPUT>;
    print R2 $line;

    $seqnum++;
    unless($seqnum%1000000){print "Sequences read: $seqnum.\n";}
}
