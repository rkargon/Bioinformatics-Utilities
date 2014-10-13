use strict;
use Data::Dumper;

my (@files) = @ARGV;

@files = sort @files;

my ($type, $rsq, $i);

foreach my $f (@files){
$rsq = `perl correlation_coefficient.pl -i "$f" -col 2 3`;
$rsq*=$rsq;

print "$f\t$rsq\n";
}

print "Sample Type\tsubsample_005\tsubsample_010\tsubsample_020\tsubsample_030\tsubsample_030_2\tsubsample_030_3\tsubsample_040\tsubsample_050\tsubsample_050_2\tsubsample_050_3\tsubsample_060\tsubsample_070\tsubsample_080\tsubsample_080_2\tsubsample_080_3\tsubsample_090\tsubsample_100";

$i=0;
foreach my $f (@files)
{
	
	unless($i%(scalar(@files)/5)){
		$f =~ m/uclust\.(q\d|all)/;
		$type = $1;
		print "\n$type\t";
	}

	$rsq = `perl correlation_coefficient.pl -i "$f" -col 2 3`;
	$rsq*=$rsq;
	print "$rsq\t\t";

	$i++;	
}

print "\n\nDone!\n\n";