#!/usr/bin/perl
# usege: perl TPM.pl -A featurecount -B featurecount.summary -O gene_TPM.txt
use strict;
use warnings;
use Cwd;
use File::Basename;
use Getopt::Long;
use List::Util qw/sum/;
my $featurecount;
my $featurecount_summary;
my $outfile;
&GetOptions ( 
			'featurecount|A=s' => \$featurecount,
			'outfile|G=s' => \$outfile,
);

    open A,"< $featurecount" or die"$!";
    #open B,"< $featurecount_summary" or die"$!";
	open OUT,"> $outfile" or die"$!";
	print OUT "geneName\tFPKM-featurecounts\n";
	
	# my $totalReads;
	# while(<B>){
	# s/\s+$//;
	# if ($_ =~ /Assigned\t(\d+)/){$totalReads = $1;last;}
	# }
	# close B;
	my @total;
	while(<A>){
	s/\s+$//;
	next if $_ =~ /[Program][Geneid]/;
	my @a = split/\t/,$_;
	push @total,$a[6];
	
}
	my $to= sum @total;
close A;
open ARP,"< $featurecount" or die"$!";
	while(<ARP>){
	s/\s+$//;
	next if $_ =~ /[Program][Geneid]/;
	my @a = split/\t/,$_;
	printf OUT $a[0]."\t"."%.3f",(($a[6]/$a[5])*1000000000)/$to;
	print OUT "\n";
}
	close OUT;
