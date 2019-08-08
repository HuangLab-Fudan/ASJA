#!/usr/bin/perl
# 还要删掉stat-end 为负数的
#usage: perl tesst.pl -A Chimeric.out.junction -O step1.txt
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use List::Util qw/sum/;
use List::Util qw/max min/;
use File::Basename;

my ($afile,$outfile);
GetOptions(
    "afile|A=s" => \$afile,
	"outfile|O=s" => \$outfile,
	
);

		 #open IN,"< F:\\project\\JUNCTION\\circ\\20181015\\Chimeric.out.junction" or die"$!";
		 #open OUT,"> F:\\project\\JUNCTION\\circ\\20181015\\step1v2-1.txt" or die"$!";
		 open A,"< $afile" or die"$!";
		 open OUT,"> $outfile" or die"$!";
		 my %checkj;
		 my $ref = {};
		 while(<A>){
		 s/\s+$//;
		 my @tmp=split/\t/;
		 next if($tmp[3]=~/_/ || $tmp[0]=~/_/ );
		 next if($tmp[3]!~/^chr/i);
		 next if($tmp[3]=~/chrM/i);
		 next if($tmp[6]<=0);
		 next if($tmp[0] ne $tmp[3]);
		 ###circRNA length max is 3228006 min 1
		 if(abs($tmp[4]-$tmp[1])>3000000){
		 next;
		 }
		 my $id;
		 my $junction_type = $tmp[6];
		 if($tmp[2] eq "+" && $junction_type==1){
			
			$id=$tmp[0]."_".($tmp[4]+1)."_".($tmp[1]-1)."_"."+";
		
		 }
		 elsif($tmp[2] eq "+" && $junction_type==2){
			
			$id=$tmp[0]."_".($tmp[4]+1)."_".($tmp[1]-1)."_"."-";
		 }
		 elsif($tmp[2] eq "-" && $junction_type==1){
			
			$id=$tmp[0]."_".($tmp[1]+1)."_".($tmp[4]-1)."_"."-";
		 }
		 else{
			
			$id=$tmp[0]."_".($tmp[1]+1)."_".($tmp[4]-1)."_"."+";
		 }
		 ###fillter postition 
		 my @check=split/_/,$id;
		 next if($check[2]-$check[1]<0);
		 my $cigar=$tmp[11] . "Z" . $tmp[13] ; 
		 #my @check=split/_/,$id;
		 #my $anti_id=join("_",$check[0],$check[2],$check[1],&restrand($check[3]));
		 push @{$ref->{$id}->{'antisense'}},0;
		 push @{$ref->{$id}->{'sense'}},0;

		 ###
		#my $legitimate=&check_badpair($check[1], $check[2], $cigar);
		
		if($junction_type==1){
		
		$checkj{$id}=1;
		push @{$ref->{$id}->{'sense'}},1;
		#push @{$ref->{$id}->{'legit'}},$legitimate;
		}
		elsif($junction_type==2){
		$checkj{$id}=1;
		push @{$ref->{$id}->{'antisense'}},1;
		#push @{$ref->{$id}->{'legit'}},$legitimate;
		}
		else{}
		 
		 }
		 
		 
		 print OUT "id\treads\tsense\tantisense\n";
		 for my $j (keys %checkj) {
		 
		  	my @up_values = @{$ref->{$j}->{'sense'}};
			my @down_values = @{$ref->{$j}->{'antisense'}};
			my $j_values = (sum(@up_values)+sum(@down_values));
			# my @legit= @{$ref->{$j}->{'legit'}};
			# my $avg=sum(@legit)/($#legit+1);
			## is essemble?
			print OUT $j,"\t",$j_values,"\t",sum(@up_values),"\t",sum(@down_values),"\n";
		 }

		 
sub restrand {
if ($_[0] eq "+"){
	return "-";
	}
elsif ($_[0] eq "-"){
	return "+";
	}
}

