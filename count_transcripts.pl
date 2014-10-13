use strict;
use Data::Dumper;

my $dir = shift(@ARGV);
my @file_patterns = @ARGV;
my (@filenames, @file_handles);
my ($tmp, $i, $line);
my @num_transcripts_array;

opendir DIR, $dir or die "Could not open dir: $!\n";
foreach my $file_pattern_tmp (@file_patterns){
    push(@filenames, grep(/$file_pattern_tmp/, readdir DIR));
}

@filenames = sort{lc($a) cmp lc($b)} @filenames;

foreach (@filenames){
    local *FILE_HANDLE;
    open FILE_HANDLE, "$dir/$_" or die "Can't open input file $_!\n$!\n";
    push (@file_handles, *FILE_HANDLE);
}

foreach $tmp (@file_handles){
    $i=0;
    while(chomp($line=<$tmp>)){
	if($line =~ m/^>/){
	     $i++;
	     if(($i%1000000)==0){print "\n".$i;}
	}
    }	
    #print "Transcripts found: $i";
    push (@num_transcripts_array, $i);
}

print "Transcripts found per file:\n";
foreach (0 .. scalar(@num_transcripts_array)-1){
    print "$filenames[$_]:\t$num_transcripts_array[$_]\n";
}
