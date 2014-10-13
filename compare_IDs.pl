use strict;

my ($subset, $superset) = @ARGV;
my (@subsetArr, @supersetArr);
my ($sbstTMP, $sprstTMP); #temp variables that store array values in comparison step
my $abort;
my $found=0;
my $i=0;
my $j=0;

open (SUPERSET, $superset) or die "Cannot open file $superset\n";
open (SUBSET, $subset) or die "Cannot open file $subset\n";
open (OUTFILE, ">anomalies.ids") or die "Cannot open file anomalies.ids\n";

#load IDs from superset file
print "Loading IDs from superset file...\n\n";
while (<SUPERSET>){
    print ".";
    chomp $_;
    push (@supersetArr, $_);
}

#load IDs from subset file
print "\nLoading IDs from subset file...\n\n";
while (<SUBSET>){
    print ".";
    chomp $_;
    push (@subsetArr, $_);
}

print "\n";

if(scalar(@subsetArr)>scalar(@supersetArr)) {print "More IDs were found in subset than in superset. Enter \'a\' to abort script: ";}
chomp($abort=<STDIN>);
if($abort eq "a") {die "Script aborted.\n\n";}

print scalar(@subsetArr) . " IDs found in subset file.\n". scalar(@supersetArr) . " IDs found in the superset file.\nPress enter to continue\n";
<STDIN>;

#print "The following IDs were found in the subset, but NOT in the superset: ";
foreach $sbstTMP (@subsetArr){
    $j++;
    print $j . "\n";
    foreach $sprstTMP (@supersetArr){
	if($sprstTMP eq $sbstTMP){
	    $found = 1;
	    last;
	}
    }
    unless($found){
	print OUTFILE $sbstTMP . "\n";
	$i++;
    }
    $found=0;
}

print "\n$i ids were found that were in the subset but not in the superset.";

print "\n\nDone!";
