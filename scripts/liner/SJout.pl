#! /usr/bin/perl
use warnings;
use strict;
use Cwd 'abs_path';
use Getopt::Long;
use File::Basename;
## perl myfusion.pl -A chimeric.out.junction -B params.txt -O outfile
#perl E:\\project\\JUNCTION\\linear\\myfusion.pl -A E:\\project\\JUNCTION\\linear\\hu7\\SJ.out.tab -B E:\\project\\JUNCTION\\linear\\hu7\\stringtie_assembly_junctions.txt -O E:\\project\\JUNCTION\\linear\\test.txt
##

my ($afile,$bfile,$outfile);
GetOptions(
    "afile|A=s" => \$afile,
	"bfile|B=s" => \$bfile,
	"outfile|O=s" => \$outfile,
);
if (defined($afile) && defined($bfile) && defined($outfile)) {

print "\nNow calculate SJ.out.tab\n"; 
open JUNCTION, "<$afile" or die $!; 
my %ref;
my $count=0;
<JUNCTION>;
EXITHERE: while (<JUNCTION>) {
	 s/\s+$//;
	my @line = split/\s+/; 
##some filtering 
	my $chrfiltering=0;
	if($line[0]=~/chr[0-9]{1,2}$/ || $line[0]=~/chrX$/ || $line[0]=~/chrY$/){
		    $chrfiltering++;
			 }
	next if ($chrfiltering==0);
	next if ($line[3] <=0);#column 8: repeat length to the left of the junction
	my $strand;
	if($line[3]==1){
		$strand="+";
	}
	else{
		$strand="-";}
	my $id = $line[0].':'.($line[1]-1).'|'.($line[2]+1).':'.$strand;
	if( exists $ref{$id}){
	   $count++;
	   
	}
	else{
		$ref{$id}=$line[6];
	}
	}
	open OUT,">$outfile" or die $!;	
	open ASS,"<$bfile" or die $!;
	<ASS>;
	print OUT "junctions\tcoverage\tread\n";
	while(<ASS>){
	 s/\s+$//;
	 my @tmp=split/\t/;
	 if(exists $ref{$tmp[0]}){
		 print OUT $_,"\t",$ref{$tmp[0]},"\n";
	 }
	 else{
		 print OUT $_,"\t","0","\n";
	 }
	 }

}

else{
print "Options are missing!\n";
}