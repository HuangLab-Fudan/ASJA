#!/usr/bin/perl
#usage: perl circ_exon.pl -A <indir> -O <outdir>

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use List::Util qw/sum/;
use File::Basename;
use List::Util qw/max min/;

$| = 1;
my ($afile,$outfile);
GetOptions(
    "afile|A=s" => \$afile,
	"outfile|O=s" => \$outfile,
	
);
	#open A,"< F:\\project\\JUNCTION\\circ\\20181015\\back\\ann\\inter2.anno" or die"$!";\
	#open OUT,"> F:\\project\\JUNCTION\\circ\\20181015\\back\\ann\\inter2.anno.res.txt" or die"$!";
	open A,"< $afile" or die"$!";
	open OUT,"> $outfile" or die"$!";
	my %trans_exon;# sort trans and exon;
	my %ref;# sort id->trans1;gene:sum(va1),trans2;gene:sum(va2)
	while(<A>){
	s/\s+$//;
	my @tmp=split/\t/;
	my @trans=split/;/,$tmp[3];
	my $transid=join(";",@trans[0..3]);
	## there has a situation :same trans can annoted for servel circRNA
	next if($tmp[12]==0);
	if(exists $ref{$tmp[9]}{$transid}){
		
		my $pre=$ref{$tmp[9]}{$transid};
		$ref{$tmp[9]}{$transid}=$pre+$tmp[12];
		###
		my $cc=$trans_exon{$tmp[9]}{$transid};
		$trans_exon{$tmp[9]}{$transid}=join(";",$trans[6],$cc);

	}
	else{
		
		$ref{$tmp[9]}{$transid}=$tmp[12];
		$trans_exon{$tmp[9]}{$transid}=$trans[6];
	}
	
	}
	foreach my $j (keys %ref){
		print OUT $j,"\t";
		my @temp;
		push @temp,"0","0";
		foreach(keys %{$ref{$j}})
			{ 	
				if ($temp[1]< $ref{$j}{$_}){
				@temp = ();
				push @temp,$_,$ref{$j}{$_};
				}
				
				#print OUT $_,"\t",$ref{$j}{$_},"\t";
			}
		print OUT join("\t",@temp),"\t";
		my $exon_num=$trans_exon{$j}{$temp[0]};
		$exon_num =~ s/ //g;
		print OUT $exon_num,"\n";
		
		
	}
