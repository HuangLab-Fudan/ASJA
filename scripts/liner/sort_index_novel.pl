use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use List::Util qw/sum/;
use File::Basename;
use List::Util qw/max min/;

my ($afile,$outdir);
GetOptions(
    "afile|A=s" => \$afile,
	"outdir|O=s" => \$outdir,
	
);
		
		 open A,"< $afile" or die"$!"; #un_ann_id_726.txt
		 
		 open OUT,"> $outdir" or die"$!";#ann_s.txt
		
		 my %ref; #junction--items
		 my %hash;#items--junction
		 
		 
		 while(<A>){
		 s/\s+$//;
		 my @tmp=split/\t/;
		 
		 if(exists $ref{$tmp[3]}){
			my $ot=$ref{$tmp[3]};
			my @pre=split/;/,$ot;
			my $new=$pre[0]."_".$tmp[0].";".$pre[1]."_".$tmp[1];
			$ref{$tmp[3]}=$new;
		 }
		 else{
			$ref{$tmp[3]}=join(";",$tmp[0],$tmp[1]);
		 }
		 ## push junction in hash there are value and reads
		 $hash{$tmp[0]}=$_;
		 }
		 foreach(keys %ref){
						
			my @arr_jc_cov=split/;/,$ref{$_};
			my @arr_cov=split/_/,$arr_jc_cov[1];
			my @arr_jc=split/_/,$arr_jc_cov[0];
			my $max= max @arr_cov;
			for my $i (0..$#arr_jc) {
				 #my ($Subscript)=grep{$sorted[$_] eq $arr_cov[$i]} 0..$#sorted; 
				 #print OUT $_,"\t";
				 #print OUT $arr_jc[$i],"\t",($Subscript+1)/($#arr_jc+1),"\n";
				 #print OUT ($arr_jc[$i]-$sorted[0])/($sorted[$#sorted]-$sorted[0]),"\n";
				 # max
				 
				 #print OUT $hash{$arr_jc[$i]},"\t";
				 #print OUT $arr_cov[$i]/$max,"\n";
				 my @novel=split/\t/,$hash{$arr_jc[$i]};
				 print OUT $novel[0],"\t",$novel[1],"\t",$novel[2],"\t",$novel[0],"\t";
				 my @trans=split/,/,$novel[3];
				 my $transid=join(";",$trans[0],$trans[4],$trans[5],$novel[4]);
				 print OUT $transid,"\t",$trans[2],"\t",$trans[3],"\t","--","\t",$arr_cov[$i]/$max,"\n"; ### using -- instead of all 
				 
			}
			
		 
		 }