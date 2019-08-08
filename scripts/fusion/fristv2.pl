#!/usr/bin/perl
#usage: perl frist.pl -A Chimeric.out.junction -O 5.3.txt
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
		 #open IN,"< F:\\project\\JUNCTION\\fusion\\20181029\\Chimeric.out.junction" or die"$!";
		 #open OUT,"> F:\\project\\JUNCTION\\fusion\\20181029\\5.3.txt" or die"$!";
		 open IN, "<$afile" or die $!; 
		 open OUT,"> $outfile" or die"$!";
		 my $ref = {};
		 my $spans= {};
		 my %checkj;
		 my %checks;
		 while(<IN>){
			s/\s+$//;
		my @tmp=split/\t/;
		next if($tmp[3]=~/_/ || $tmp[0]=~/_/ );
		next if($tmp[3]!~/^chr/ || $tmp[0]!~/^chr/);
		next if($tmp[3]=~/chrM/i || $tmp[0]=~/chrM/i); # delete chrM
        next if(abs($tmp[1]-$tmp[4])<3000000 && $tmp[3] eq $tmp[0]); #delete same chrom and length lesss 30kb
        # from star doc:
        #The rst 9 columns give information about the chimeric junction:

        #The format of this le is as follows. Every line contains one chimerically aligned read, e.g.:
        #chr22 23632601 + chr9 133729450 + 1 0 0 SINATRA-0006:3:3:6387:56650 23632554 47M29S 133729451 47S29M40p76M
        #The first 9 columns give information about the chimeric junction:

        #column 0: chromosome of the donor
        #column 1: rst base of the intron of the donor (1-based)
        #column 2: strand of the donor
        #column 3: chromosome of the acceptor
        #column 4: rst base of the intron of the acceptor (1-based)
        #column 5: strand of the acceptor
        #column 6: junction type: -1=encompassing junction (between the mates), 1=GT/AG, 2=CT/AC  type 1 means to sense , type 2 means to antisense
        #column 7: repeat length to the left of the junction
        #column 8: repeat length to the right of the junction
        #Columns 9-13 describe the alignments of the two chimeric segments, it is SAM like. Alignments are given with respect to the (+) strand
        #column 9: read name
        #column 10: rst base of the rst segment (on the + strand)
        #column 11: CIGAR of the rst segment
        #column 12: rst base of the second segment
        #column 13: CIGAR of the second segment

        my $junction_type = $tmp[6];
        
        my $read_name = $tmp[9]; ### read name is used
        my ($chrA, $posA, $strandA) = ($tmp[0], $tmp[1], $tmp[2]);
		if($strandA=~/\+/){$posA--;}
		else{$posA++;}
        my ($rst_A, $cigar_A) = ($tmp[10], $tmp[11]);
        
        my ($chrB, $posB, $strandB) = ($tmp[3], $tmp[4], $tmp[5]);
		if($strandB=~/\+/){$posB++;}
		else{$posB--;}       
        my ($rst_B, $cigar_B) = ($tmp[12], $tmp[13]);
		my @A_hits; 
        my @B_hits; 
        #my ($genome_coords_aref, $read_coords_aref) = &get_genome_coords_via_cigar($rst, $cigar);
		my $id = join("_", $chrA, $posA, $strandA ,$chrB, $posB, $strandB);
        # adjust sense(1) or antisense(2),like this:chr12_11869970_+_chr15_87940754_-   vs   chr15_87940754_+_chr12_11869970_-
		my $invStrandA = &reversestrand($strandA);
		my $invStrandB = &reversestrand($strandB);
		my $anti_id=join("_",$chrB, $posB,$invStrandB,$chrA, $posA,$invStrandA);
		# becasue line 109 warrning we shuold defined these var
		push @{$ref->{$id}->{'antisense'}},0;
		push @{$ref->{$id}->{'sense'}},0;
		push @{$ref->{$anti_id}->{'antisense'}},0;
		push @{$ref->{$anti_id}->{'sense'}},0;
		if($junction_type==1){
		##get junction read
		
		$checkj{$id}=1;
		push @{$ref->{$id}->{'sense'}},1;
		}
		elsif($junction_type==2){
		if(exists $checkj{$anti_id}){
		push @{$ref->{$anti_id}->{'antisense'}},1;
			}
		else{
		$checkj{$anti_id}=1;
		push @{$ref->{$anti_id}->{'antisense'}},1;
			}
		}
		elsif($junction_type==0){}
		elsif($junction_type==-1){##get spanning read
		
		push @{$spans->{$id}->{'antisense'}},0;
		push @{$spans->{$id}->{'sense'}},0;
		if(exists $checks{$anti_id}){
		
		push @{$spans->{$anti_id}->{'antisense'}},1;
		}
		else{
		push @{$spans->{$id}->{'sense'}},1;
		$checks{$id}=1;
		}		
		
		}
		
		
		}
		close IN;
		print OUT "ID\tread\tsense\tantisense\tspanReads\n";
		for my $j (keys %checkj) {
			my @tmpj=split/_/,$j;
		    my @up_values = @{$ref->{$j}->{'sense'}};
			my @down_values = @{$ref->{$j}->{'antisense'}};
			my $j_values = (sum(@up_values)+sum(@down_values));
			next if($j_values<=1);## is essemble?
			
			my $spanRead=0;
			for my $s (keys %checks)
			{ 
				next if($j eq $s);
				my @tmps=split/_/,$s;
				if($tmpj[0] eq $tmps[0] && $tmpj[2] eq $tmps[2] && $tmpj[3] eq $tmps[3] && $tmpj[5] eq $tmps[5] && (abs($tmpj[1]-$tmps[1])<=500)&& (abs($tmpj[4]-$tmps[4])<=500)){
							my @sup_values = @{$spans->{$s}->{'sense'}};
							my @sdown_values = @{$spans->{$s}->{'antisense'}};
							$spanRead=(sum(@sup_values)+sum(@sdown_values))+$spanRead;
				}
				##like this j:chr12_11869764_+_chr15_87940691_-   s:chr15_87940652_+_chr12_11869877_-  is useful?
				elsif (&reversestrand($tmpj[2]) eq $tmps[5] && &reversestrand($tmpj[5]) eq $tmps[2] && $tmpj[0] eq $tmps[3] && $tmpj[3] eq $tmps[0] && (abs($tmpj[4]-$tmps[1])<=500) && (abs($tmpj[1]-$tmps[4])<=500) ) {
							my @sup_values = @{$spans->{$s}->{'sense'}};
							my @sdown_values = @{$spans->{$s}->{'antisense'}};
							$spanRead=(sum(@sup_values)+sum(@sdown_values))+$spanRead;
				}
			
			}
			if($spanRead>=1){
				print OUT "$j\t",sum(@up_values)+sum(@down_values),"\t",sum(@up_values),"\t",sum(@down_values),"\t",$spanRead,"\n";
			
			}
		}
		
sub reversestrand {
	if ($_[0] eq "+"){
		return "-";
	}
	elsif ($_[0] eq "-"){
		return "+";
	}
}
