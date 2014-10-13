use strict;
use Data::Dumper;

my $LOG2 = log(2);

# $f = temp file handle for each file
# $l = temp var, stores each line in files
# $o = temp output file handle
# $out_str = stores output string to print to file
my ($f, $l, $o, $out_str);

my @a;

foreach (@ARGV){
	print "Reading file $_...\n";
	open $f, $_ or die "Can't open input file!\n$!\n";
	open $o, ">$_.log2" or die "Can't open output file!\n$!\n";
	
	while(chomp($l = <$f>)){
		@a = split("\t", $l);
		
		#prints first column, log2 of second, and log2 of third
		#eg "2013	56	32" -> "2013	5.8073	5"
		#if 2nd or 3rd column is <=0 or not a num, value is unchanged
		$out_str = $a[0]."\t".(($a[1]>0) ? log($a[1])/log(2) : $a[1])."\t".(($a[2]>0) ? log($a[2])/log(2) : $a[2])."\n";
		
		print $o $out_str;
	}
}

print "\n\nDone!\n\n";