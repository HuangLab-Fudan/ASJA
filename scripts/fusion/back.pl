#!/usr/bin/perl
#usage:
## perl back -A step1V2.txt -B liner.txt -O ratio.txt
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

my %start;
my %end;
my %len;

## base on NC paper 's figure and position of chromsomes define left(star) and right(end) 
#

 open FUS,"< $afile" or die"$!";
 <FUS>;
 while(<FUS>){ #read circRNA
     s/\s+$//;
	 my @tmp = split/\t/;
	 my @fu=split/_/,$tmp[0];
	 my $point_start=join("_",$fu[0],$fu[1],$fu[2]);####
	 my $point_end=join("_",$fu[3],$fu[4],$fu[5]);####
	 
	 
	 if(exists $start{$point_start}){ ##start
	    
	    my $value=$start{$point_start};
		my $vb=join("_",$value,$tmp[3]+$tmp[2]);
		$start{$point_start}=$vb;
	 }
     else{
	    $start{$point_start}=$tmp[3]+$tmp[2];
	 }
	 if(exists $end{$point_end}){ ##end
	    
	    my $value=$end{$point_end};
		my $vb=join("_",$value,$tmp[3]+$tmp[2]);
		$end{$point_end}=$vb;
	 }
     else{
	    $end{$point_end}=$tmp[3]+$tmp[2];
	 }
	 
}
close FUS;

foreach (keys %start){
  my $count=$start{$_};
  my @Scount=split/_/,$count;
  my $countall= sum @Scount;
  $start{$_}=$countall; # may be error
  
 }
 foreach (keys %end){
  my $count=$end{$_};
  my @Scount=split/_/,$count;
  my $countall= sum @Scount;
  $end{$_}=$countall; # may be error
  
 }
	open JUN,"< $bfile" or die"$!";
	<JUN>;
	while(<JUN>){
	 s/\s+$//;
	 my @tmp=split/\t/;
	 my @jc=split/:/,$tmp[0];
	 my @jc2=split/\|/,$jc[1];
	 my $chr=$jc[0];
	 my $stand=$jc[2];
	 my $st=$jc2[0];
	 my $ed=$jc2[1];
	 my $post_start=join("_",$chr,$st,$stand);
	 my $post_end=join("_",$chr,$ed,$stand);
	 ### because A-B fusion ,there is not sequential order
	 if(exists $start{$post_start}){ ##
		my $pre=$start{$post_start};
		my $new=join(";",$pre,$tmp[2]);
		$start{$post_start}=$new;
	 }
	 if(exists $start{$post_end}){ ##
		my $pre=$start{$post_end};
		my $new=join(";",$pre,$tmp[2]);
		$start{$post_end}=$new;
	 }	 
	 
	 
	 if(exists $end{$post_end}){ ##
		my $pre=$end{$post_end};
		my $new=join(";",$pre,$tmp[2]);
		$end{$post_end}=$new;
	 }
	 if(exists $end{$post_start}){ ##
		my $pre=$end{$post_start};
		my $new=join(";",$pre,$tmp[2]);
		$end{$post_start}=$new;
	 }	 
	 
	 
	}
	close JUN;
	
	#open ST,"> $outstart" or die"$!";
	#open ED,"> $outend" or die"$!";
	###output start
	foreach(keys %start){
		my $va=$start{$_};
		my @value=split/;/,$va;
		my $base=sum @value;
		my $ratio=$value[0]/$base;
		$start{$_}=$ratio;
		
		#print ST $_,"\t",$va,"\t",$ratio,"\n";
	}
	
		foreach(keys %end){
		my $va=$end{$_};
		my @value=split/;/,$va;
		my $base=sum @value;
		my $ratio=$value[0]/$base;
		$end{$_}=$ratio;
		
		#print ED $_,"\t",$va,"\t",$ratio,"\n";
	}
	
	### interget data
	open IN,"< $afile" or die"$!";
	open OUT,"> $outfile" or die"$!";
	<IN>;
	print OUT "fusionID\tsense\tantisense\tspan_reads\tleftbackratio\trightbackratio\n";
	while(<IN>){
    s/\s+$//;
	 my @tmp = split/\t/;
	 my @fu=split/_/,$tmp[0];
	 my $point_start=join("_",$fu[0],$fu[1],$fu[2]);####
	 my $point_end=join("_",$fu[3],$fu[4],$fu[5]);####
	 if(exists $start{$point_start}){
	 print OUT $_,"\t",$start{$point_start},"\t";
	 }
	 if(exists $end{$point_end}){
	 print OUT $end{$point_end};
	 }
	 print OUT "\n";
	}