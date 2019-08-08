#!/usr/bin/perl
#usage:
## perl back -A sort.exons.bed -B 5.3_ratio.txt -O 5.3.ann.txt
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
my %refstart;
my %refend;
my %start;
my %end;
my %len;

## base on NC paper 's figure and position of chromsomes define left(star) and right(end) 
#

	open EXO,"< $afile" or die"$!";
	while(<EXO>){
	    s/\s+$//;
	 my @tmp = split/\t/;
	 my $start=join("_",$tmp[0],$tmp[1],$tmp[5]);
	 my $end=join("_",$tmp[0],$tmp[2],$tmp[5]);
	 my @trans=split/;/,$tmp[3];
	 my $transid=join(";",@trans[0..3],$trans[6]);
	 	 if(exists $refstart{$start})
	 {	my $pre=$refstart{$start};
		$refstart{$start}=join(",",$transid,$pre);
		}
	 else{
	 $refstart{$start}=$transid;
	 }
	 if(exists $refend{$end})
	 {	my $pre=$refend{$end};
		$refend{$end}=join(",",$transid,$pre);
		}
	 else{
	 $refend{$end}=$transid;
	 }	 
	 
	
	}
 open OUT ,"> $outfile" or die "$!";
         my @temp_dir=split/\//,$bfile;
		 if($temp_dir[$#temp_dir]=~/ratio/){
		 print OUT "fusionID\tread\tGT_AG_reads\tCT_AC_reads\tspan_reads\tleftbackratio\trightbackratio\tleft_type\tleftann\tright_type\trightann\n";		 
		 }
		else{
		 print OUT "fusionID\tread\tGT_AG_reads\tCT_AC_reads\tspan_reads\tleft_type\tleftann\tright_type\trightann\n";	
		}
 my $path_b="$bfile"; ##/home/G/JUNCTION/assembly2/MBR560723/circ/5.3_ratio.txt
 my @path=split/\//,$path_b;
 pop @path;
 my $temp_path=join("/",@path);
 print $temp_path,"\n"; 
 open FUS,"< $bfile" or die"$!";
 <FUS>;
 while(<FUS>){ #read fusion
     s/\s+$//;
	 my @tmp = split/\t/;
	 my @fu=split/_/,$tmp[0];
	 my $point_start=join("_",$fu[0],$fu[1],$fu[2]);####
	 my $point_end=join("_",$fu[3],$fu[4],$fu[5]);####
	 	 my $close_ann;
	 if(exists $refstart{$point_start}){
		print OUT $_, "\t","exon","\t",$refstart{$point_start},"\t";
	 }
	 elsif(exists $refend{$point_start}){
	    print OUT $_,"\t","exon","\t",$refend{$point_start},"\t";
	 }
	 else{
		$close_ann=&closed($fu[0],$fu[1]);
		print OUT join("\t",@tmp),"\t","intron/NA","\t","gene_name:",$close_ann,"\t";
	 }
	 
	 if(exists $refstart{$point_end}){
		print OUT "exon","\t",$refstart{$point_end},"\n";
	 }
	 elsif(exists $refend{$point_end}){
	   print OUT "exon","\t",$refend{$point_end},"\n";
	 }
	 else{
		$close_ann=&closed($fu[3],$fu[4]);
	  print OUT "intron/NA","\t","gene_name:",$close_ann,"\n";
	 }
}
close FUS;

sub closed{
	my($chr,$pos)=@_;
	my $temp=join("/",$temp_path,"tmp.bed");
	my $tempann=join("/",$temp_path,"tmp.anno");
	#print $chr,$pos,"---","\n";
	open TEMP ,"> $temp" or die "$!";
	print TEMP $chr,"\t",$pos-1,"\t",$pos;
		 my $cmd = "bedtools closest -t first -D b -a $temp -b $afile > $tempann";
		 system("$cmd");
	 open ANN, "< $tempann" or die"$!";
	 my $out;
	 while(<ANN>){
	 s/\s+$//;
	 $out=$_;
	 }
	 my $c_gene;
	 if ($out =~ /gene_name (\S+);?/) {
            $c_gene = $1;
            $c_gene =~ s/[\"\']//g;
        }
	 #print $c_gene,"\n";
	 return "$c_gene";
	 
	}