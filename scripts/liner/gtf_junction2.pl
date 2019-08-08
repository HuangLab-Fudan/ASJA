#!/usr/bin/perl
#usage: perl gtf_junctions.pl -G <gtf_file> -I <junction_id> -O <ann_file>

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use List::Util qw/max min/;
$| = 1;
$| = 1;
my ($gtf,$id,$outfile);
GetOptions(
    "gtf|G=s" => \$gtf,
	"id|I=s" => \$id,
	"outfile|O=s" => \$outfile,
);

if (defined($gtf)) {
		my @sample=split/\//,$gtf;
		my $fn=$sample[$#sample-1];
		print $fn;
		open GTF,"< $gtf" or die"$!";
		my @exon1 = ();
		my $strand = ();
		my $va=();
		my $tranpos;
		my %ref;
		my %anti;
		my $IDtrans;
		my @transexon;
	while (<GTF>) {
	    next if (/^#/);
		s/\s+$//;
		my @tmp = split/\t/;
		if ($tmp[2] eq 'transcript') {
			$tmp[8] =~ /TPM \"(.*?)\";/;
			$va = $1;
		    @exon1 = ();
			if ($tmp[6] =~ /\./) {
			    $strand = '+';
			} else {
			    $strand = $tmp[6];
			}
			$tranpos=join(":",$tmp[0],$tmp[3],$tmp[4],$strand);
			#
			my $tid;
			my $gid ;
			my $gname;
			my $gtype;
				if ($tmp[8] =~ /reference_id \"(.*?)\";/){$tid = $1;}
				else{$tid="na";
				}
			    if($tmp[8] =~ /ref_gene_id \"(.*?)\";/){ $gid = $1;}
				else{ $gid="na";
				}
				if( $tmp[8] =~ /ref_gene_name \"(.*?)\";/){ $gname = $1;}
				else{ $gname="na";
				}
				$IDtrans=join(",",$tranpos,$tid,$gid,$gname,$va,$fn);
				#print $IDtrans,"\n";
				#
		} elsif ($tmp[2] eq 'exon') {
		    if (@exon1 == 0) {
				@transexon=();
			    push @exon1,@tmp[0,3,4],$strand;
				#
				push @transexon,@tmp[3,4];
				#
			} elsif (@exon1 != 0) {
				push @transexon,@tmp[3,4];
			    my $junction = $tmp[0].':'.$exon1[2].'|'.$tmp[3].':'.$exon1[3];
				$tmp[8] =~ /reference_id \"(.*?)\";/;
			    my $tid = $1;
				if(!$tid){
				$tid="na";
				}
			    $tmp[8] =~ /ref_gene_id \"(.*?)\";/;
			    my $gid = $1;
				if(!$gid){
				$gid="na";
				}
			    $tmp[8] =~ /ref_gene_name \"(.*?)\";/;
			    my $gname = $1;
				if(!$gname){
				$gname="na";
				}
			    #print OUT "$junction\t$tid\t$gid\t$gname\t$va\t$fn\n";
				my $t2=join(",",$tranpos,$tid,$gid,$gname,$va,$fn);
				if(exists $ref{$junction}){
					my $tp=$ref{$junction};
					my $now=join(";",$tp,$t2);
					$ref{$junction}=$now;
				}
				else{
					$ref{$junction}=$t2;
				}
				
				#
				if(exists $anti{$IDtrans}){
				 my $ot=$anti{$IDtrans};
				 $anti{$IDtrans}=join(",",$ot,@transexon);
				}
				else{
				 $anti{$IDtrans}=join(",",@transexon);
				}
				@transexon=();
				#
				@exon1 = ();
				push @exon1,@tmp[0,3,4],$strand;
			}
		}
	}
	close GTF;
	open ID,"< $id" or die"$!";
	open OUT ,"> $outfile" or die"$!";
	<ID>;
	my %jc;
	while(<ID>){
		s/\s+$//;
		my @ot=split/\t/;
		if(exists $ref{$ot[0]}){
		
			my @output=split/,/,$ref{$ot[0]};
			my @oushu;
			
			for( my $i=4;$i<=$#output;$i=$i+5){
			   push @oushu,$output[$i];
			   #print OUT $output[$i],"\n";
			   
			}
			 my $big=max @oushu;
			         ##print OUT $_,"\t",join("\t",@oushu),"\t",$big,"\n";
			 my ($Subscript)=grep{$oushu[$_] eq $big} 0..$#oushu;
			         ##print OUT $Subscript,"\n";
			  my @list=split/;/,$ref{$ot[0]};
			  
			  my $outexon=$anti{$list[$Subscript]};
			  
			  print OUT $_,"\t",$list[$Subscript],"\t",$anti{$list[$Subscript]},"\n";
		}
	
	}

	close ID;
	close OUT;
	
	}

else{
	print "Options are missing!\n";
}
