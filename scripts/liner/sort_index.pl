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
		 
		 <A>;
		 while(<A>){
		 s/\s+$//;
		 my @tmp=split/\t/;
		 
		 if(exists $ref{$tmp[5]}){
			my $ot=$ref{$tmp[5]};
			my @pre=split/;/,$ot;
			my $new=$pre[0]."_".$tmp[0].";".$pre[1]."_".$tmp[1];
			$ref{$tmp[5]}=$new;
		 }
		 else{
			$ref{$tmp[5]}=join(";",$tmp[0],$tmp[1]);
		 }
		 ## push junction in hash there are value and reads
		 $hash{$tmp[0]}=$_;
		 }
		 print OUT "junctions\tcovarage\tread\tjunction\ttransID\tgeneID\tgene\ttype\tWeight ratio\n";
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
				 
				 print OUT $hash{$arr_jc[$i]},"\t";
				 print OUT $arr_cov[$i]/$max,"\n";
			}
			
		 
		 }