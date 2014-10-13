use strict;

my ($filename) = @ARGV;
my $line;
my $num_lines_read;
my $num_bases=0;

open INFILE, $filename or die "Can't open input file!\n$!\n";

while (chomp($line=<INFILE>)){
    unless($line =~ m/[^a-z]/i or length($line)==0){
	$num_bases+= length($line);
	$num_lines_read++;
    }
    unless ($num_lines_read % 1000000){print "Lines read:\t$num_lines_read\tTotal Bases:\t$num_bases\n";}
}
print "Counting finished.\nLines read:\t$num_lines_read\tTotal Bases:\t$num_bases\n";
print "\n\nDone!\n\n";
