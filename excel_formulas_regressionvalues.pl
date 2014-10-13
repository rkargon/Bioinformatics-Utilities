use strict;

open OUTFILE, ">regressionformulas.txt" or die "Can't open output file!\n\$!\n";
my @letters_arr=( "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ", "BA", "BB", "BC", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BK", "BL", "BM", "BN", "BO");
my $i=1;
#"=RSQ(B14:B99999, C14:C99999)";

print OUTFILE "Total\t\t";

#formula for total regression value
for (1 .. 17){
	print OUTFILE "=RSQ(".$letters_arr[$i-1]."14:".$letters_arr[$i-1]."99999, ".$letters_arr[$i]."14:".$letters_arr[$i]."99999)";
	print OUTFILE "\t\t\t\t";
	$i+=4;
}

print OUTFILE "\nTop 25%\t\t";
$i=1;

for (1 .. 17){
	print OUTFILE "=RSQ(INDIRECT(\"".$letters_arr[$i-1]."\"\&\$".$letters_arr[$i]."\$10):INDIRECT(\"".$letters_arr[$i-1]."\"\&\$".$letters_arr[$i]."\$7),INDIRECT(\"".$letters_arr[$i]."\"\&\$".$letters_arr[$i]."\$10):INDIRECT(\"".$letters_arr[$i]."\"\&\$".$letters_arr[$i]."\$7))";
	print OUTFILE "\t\t\t\t";
	$i+=4;
}

print OUTFILE "\nThird Quartile%\t\t";
$i=1;

for (1 .. 17){
	print OUTFILE "=RSQ(INDIRECT(\"".$letters_arr[$i-1]."\"\&\$".$letters_arr[$i]."\$9):INDIRECT(\"".$letters_arr[$i-1]."\"\&\$".$letters_arr[$i]."\$10),INDIRECT(\"".$letters_arr[$i]."\"\&\$".$letters_arr[$i]."\$9):INDIRECT(\"".$letters_arr[$i]."\"\&\$".$letters_arr[$i]."\$10))";
	print OUTFILE "\t\t\t\t";
	$i+=4;
}

print OUTFILE "\nSecond Quartile%\t\t";
$i=1;

for (1 .. 17){
	print OUTFILE "=RSQ(INDIRECT(\"".$letters_arr[$i-1]."\"\&\$".$letters_arr[$i]."\$8):INDIRECT(\"".$letters_arr[$i-1]."\"\&\$".$letters_arr[$i]."\$9),INDIRECT(\"".$letters_arr[$i]."\"\&\$".$letters_arr[$i]."\$8):INDIRECT(\"".$letters_arr[$i]."\"\&\$".$letters_arr[$i]."\$9))";
	print OUTFILE "\t\t\t\t";
	$i+=4;
}

print OUTFILE "\nBottom 25%\t\t";
$i=1;

#formula for 1st quartile regression value
for (1 .. 17){
	print OUTFILE "=RSQ(".$letters_arr[$i-1]."14:INDIRECT(\"".$letters_arr[$i-1]."\"\&\$".$letters_arr[$i]."\$8), ".$letters_arr[$i]."14:INDIRECT(\"".$letters_arr[$i]."\"\&\$".$letters_arr[$i]."\$8))";
	print OUTFILE "\t\t\t\t";
	$i+=4;
}

print OUTFILE "\n\t\t";
$i=1;

print "\n\nDone!\n\n";