use strict;
use Data::Dumper;

my $n = shift(@ARGV);
my @filenames = @ARGV;

my ($line, @lineArr);
my @file_array;
my @total_array;
my $line_num=0;
my $file_num=0;
my $max_file_size=0;;

#for each file...
foreach (@filenames)
{
	print "Loading $_ into array...\n";
    open FILEHANDLE, $_ or die "Can't open file $_!\n$!\n\n";

    while(chomp($line=<FILEHANDLE>)){
	@lineArr = split("\t", $line);
	push(@file_array, $lineArr[$n-1]);
    }

    push(@total_array, [@file_array]);
    @file_array=();

    close FILEHANDLE;
}

for (0 .. scalar(@total_array)-1){
	#print "file $_ length: ".scalar(@{$total_array[$_]}) . "\n";
	if(scalar(@{$total_array[$_]}) > $max_file_size){$max_file_size = scalar(@{$total_array[$_]});}
}

print "\nmaxsize:$max_file_size\n";

open OUTFILE, ">$filenames[0].$n.combined_columns" or die "can't open output file!\n$!\n";

print "Printing to output file $filenames[0].$n.combined_columns...\n";

print OUTFILE join("\t", @filenames) . "\n";
for($line_num=0; $line_num < $max_file_size; $line_num++){
    
    for($file_num=0; $file_num < scalar(@total_array); $file_num++){
		if($total_array[$file_num][$line_num]){print OUTFILE $total_array[$file_num][$line_num];}
		print OUTFILE  "\t";	
    }
    
    unless($line_num%10000){print "$line_num lines read...\n";}
    
    print OUTFILE "\n";
}

#print Dumper @total_array;
