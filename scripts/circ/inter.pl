#!/usr/bin/perl
#usage: perl tesst.pl -A Chimeric.out.junction -O step1.txt
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use List::Util qw/sum/;
use List::Util qw/max min/;
use File::Basename;

my ($afile,$bfile,$outfile);
GetOptions(
    "afile|A=s" => \$afile,
	"bfile|B=s" => \$bfile,
	"outfile|O=s" => \$outfile,
	
);

		
		 open A,"< $afile" or die"$!";
		 open B,"< $bfile" or die"$!";
		 open OUT,"> $outfile" or die"$!";
		 my %ref;
		 while(<A>){
		 s/\s+$//;
		 my @tmp=split/\t/;
		 $ref{$tmp[0]}=$_;
		 }
		 #print OUT "circID\tread\tGT_AG_read\tCT_AC_read\tleft_backratio\tright_backratio\tcircID\tannotaion\tlength_exon\tpos_exon\n";
		 <B>;
		 my @temp_dir=split/\//,$bfile;
		 if($temp_dir[$#temp_dir]=~/ratio/){
		 print OUT "circID\tread\tGT_AG_read\tCT_AC_read\tleft_backratio\tright_backratio\tcircID\tannotaion\tlength_exon\tpos_exon\n";
		 }
		 else{
		 print OUT "circID\tread\tGT_AG_read\tCT_AC_read\tcircID\tannotaion\tlength_exon\tpos_exon\n";
		 }
		 while(<B>){
		 s/\s+$//;
		 my @tmp=split/\t/;
		 if($ref{$tmp[0]}){
		  print OUT $_,"\t",$ref{$tmp[0]},"\n";
		 }
		 else{
		  print OUT $_,"\tNA\tNA\tNA\tNA\n";
		 }
		 }