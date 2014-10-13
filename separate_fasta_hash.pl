use strict;
use Data::Dumper;

my ($filename, $ids_file) = @ARGV;
my %ids;

#load ids into @ids
print "Reading IDs file...\n";
%ids = %{LoadIDs ($ids_file, \%ids)};

print "Reading sequences file...";
ReadSeqs ($filename, \%ids);

print "\n\nDone!";

sub LoadIDs
{
    my ($ids_file, $ids_ref) = @_;
    my %ids = %{$ids_ref};
    my $id_tmp;

    #open IDs file
    open (IDS, $ids_file) or die "Unable to open IDs file: $!\n";

    while ($id_tmp=<IDS>){
	print ".";
	chomp($id_tmp);
	$ids{$id_tmp} = 1;
    }

    print "Done reading IDs. ".keys(%ids)." IDs found.\n";

    #return reference of IDs hash
    return (\%ids);
}

sub ReadSeqs
{
    my ($filename, $ids_ref) = @_;
    %ids = %{$ids_ref};
    my ($seqCompid, $currSeq, $line);
    my $isFirstSeq = 1;
    my $isInList = 0;
    my $i=0;

    print "\nOpening files...\n";

    #open necessary files
    open (SEQS, $filename) or die "Unable to open sequences file: $!\n";
    open (INLIST, ">$filename.inlist") or die "Unable to open output sequences file: $!\n";
    open (NOTINLIST, ">$filename.notinlist") or die "Unable to open output sequences file: $!\n";

    print "Reading FASTA file: \n";

    #read FASTA file line-byline
    while ($line = <SEQS>){
	if ($line =~ m/>/){
	    if($isFirstSeq){
		$isFirstSeq = 0;
	    }
	    else{
		if($isInList){print INLIST $currSeq;}
		else{print NOTINLIST $currSeq;}
		print ".";
		$i++;
		unless($i%1000){print "\n$i: ";}

		$currSeq = "";
	    }
	    
	    $line =~ m/(comp.*?)[\s:]/;
	    $seqCompid = $1;
	    
	    $isInList = CheckID($seqCompid, \%ids);

	}

	$currSeq .= $line;
    }

}

sub CheckID
{
    my ($seqCompid, $ids_ref) = @_;
    %ids = %{$ids_ref};

    if($ids{$seqCompid}){return(1);}
    else {return (0);}
    
}
