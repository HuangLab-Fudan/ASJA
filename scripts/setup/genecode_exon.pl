#!/usr/bin/perl
#usage:
## perl back -G -O exon
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use List::Util qw/sum/;
use List::Util qw/max min/;
use File::Basename;


my ($afile,$outfile);
GetOptions(
    "afile|G=s" => \$afile,
	"outfile|O=s" => \$outfile,
	
);

my %start;
my %end;
my %len;

## base on NC paper 's figure and position of chromsomes define left(star) and right(end) 
#
 open GTF,"< $afile" or die"$!";
 open OUT,"> $outfile" or die"$!";
 <GTF>;
 <GTF>;
 <GTF>;
 <GTF>;
 <GTF>;
 
 while(<GTF>){
 s/\s+$//;
 my @tmp=split/\t/;
 if($tmp[2]=~/exon/){
	print OUT join("\t",$tmp[0],$tmp[3],$tmp[4],$tmp[8],"0",$tmp[6]),"\n";
 }
 
 }
