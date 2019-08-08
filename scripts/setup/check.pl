#!/usr/bin/perl
#usage: perl intersectionAll.pl -A /home/H/exosomes/ref/gencode.v22.annotation_junctions.txt -B result_fc_10_median_freq_05_10.txt -O tmp -C 1,1 -S AB
#一个junction对应多个gene???
use strict;
use warnings;
use File::Basename;
use Getopt::Long;

my ($afile,$bfile,$columns,$outdir,$outstyle);
GetOptions(
    "afile|A=s" => \$afile,
	"outdir|O=s" => \$outdir,
	
);

open A,"< $afile" or die"$!";
open OUT,"> $outdir" or die"$!";
<A>;
# my %hash;
# while(<A>){
# s/\s+$//;
# my @tmp=split/\t/;
# if(exists $hash{$tmp[0]}){
# my $old=$hash{$tmp[0]};
# my $new=$tmp[3].",".$old;
# $hash{$tmp[0]}=$new;
# }
# else{
# $hash{$tmp[0]}=$tmp[3];
# }
# }
# foreach(keys %hash){
# print OUT $_,"\t";
# my @array=split/,/,$hash{$_};
# my %h;
# my @uniq_times = grep { ++$h{ $_ } < 2; } @array;
# print OUT join(",",@uniq_times),"\t",$#uniq_times,"\n";
# }
	my %ref;
	while(<A>){
	s/\s+$//;
	my @tmp=split/\t/;
	#push @{$ref->{$tmp[0]}->{$tmp[3]}},$_;
	$ref{$tmp[0]}{$tmp[3]}=$_;
	}
	
	for my $j (keys %ref) {
	my @a=keys %{$ref{$j}};
	if($#a==0){
		print OUT $ref{$j}{$a[0]},"\n";
	}
	else{
		for my $gene(keys %{$ref{$j}}){
		if($gene=~/-/){
			if($gene=~/HLA.*/){
				print OUT $ref{$j}{$gene},"\n";
				last;
			}
		}
		elsif($gene=~/\./)
		{
		}
		else{
			print OUT $ref{$j}{$gene},"\n";
			last;
		}
	
	}
	}

	

	}
