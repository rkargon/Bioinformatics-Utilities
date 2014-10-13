use strict;

my @filenames = @ARGV;
my $outfile = ">".$filenames[0].".combined";
my @file_handles;
my $data_left=1;
my $text="";
my $input;

#load up file handles
foreach (@filenames){
    local *FILE_HANDLE;
    open FILE_HANDLE, "$_" or die "Can't open input file $_!\n$!\n";
    push (@file_handles, *FILE_HANDLE);
}

open OUTFILE, $outfile or die "Can't open output file!\n$!\n";

while($data_left){
	$data_left=0; #will only become true again if files are left
	foreach my $handle (@file_handles){
		if(chomp($input=<$handle>)){
			$text.=($input."\t");
			$data_left++;
		}
		else{$text .= " \t \t \t";}
		
	}
	$text.="\n";
}

print OUTFILE $text;

print "\n\nDone!\n\n";