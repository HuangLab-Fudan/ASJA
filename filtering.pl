#!/usr/bin/perl
#usage: perl filtering.pl -read <1> -ratio <0.08> -IN <inputfile> -O <otufile> -linear/backsplicing/fusion

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use List::Util qw/min sum/;
use Cwd;
use Cwd 'abs_path';
$| = 1;
#	-liner            liner junction
#	-backsplicing            backsplicing junction
#	-fusion            fusion junction
my ($filter_read,$filter_ratio,$input,$outfile);
my $linear=0;
my $backsplicing=0;
my $fusion=0;
GetOptions(
    "filter_read|read=s" => \$filter_read,
    "filter_ratio|ratio=s" => \$filter_ratio,
	"input|IN=s" => \$input,
	"outfile|O=s" => \$outfile,
	'linear' => \$linear,
	'backsplicing' => \$backsplicing,
	'fusion' => \$fusion,
);

    open A,"< $input" or die"$!";
	open OUT,"> $outfile" or die"$!";
	my $ah = <A>;
	my @header=split/\t/,$ah;
	my ($pos_read)=grep{$header[$_] eq 'read'} 0..$#header;
	my ($pos_ratio)=grep{$header[$_]=~/ratio/} 0..$#header;
	print "read column:",$pos_read," cut off:",$filter_read,"\t","ratio column:",$pos_ratio," cut off:",$filter_ratio,"\n";
	print OUT $ah;
if($linear){
	while(<A>){
			    s/\s+$//;
			my @tmp = split/\t/;
			next if($tmp[$pos_read]<$filter_read);
			next if($tmp[$pos_ratio]<$filter_ratio);
			print OUT $_,"\n";
	}
	close A;
}
elsif($backsplicing){
	while(<A>){
			    s/\s+$//;
			my @tmp = split/\t/;
			next if($tmp[$pos_read]<$filter_read);
			next if(($tmp[$pos_ratio]+$tmp[$pos_ratio+1])/2<$filter_ratio);
			print OUT $_,"\n";
	}
	close A;
}
else{
	while(<A>){
			    s/\s+$//;
			my @tmp = split/\t/;
			if($tmp[7]=~/exon/ || $tmp[9]=~/exon/){
			next if($tmp[$pos_read]<$filter_read);
			next if(($tmp[$pos_ratio]+$tmp[$pos_ratio+1])/2<$filter_ratio);
			print OUT $_,"\n";
			}

	}
	close A;
}
close OUT;