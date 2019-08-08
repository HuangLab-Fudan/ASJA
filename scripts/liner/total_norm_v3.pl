#!/usr/bin/perl
#sed 's/[\t]*$//g' gencode_CE_norm.txt >1.txt //delet the TAB of gencode_CE_norm.txt and save in 1.txt
#usage: perl total_norm_v3.pl -A /home/D/TST/ref/gencode.v25.annotation_junctions.txt -B 198_Noraml.txt -O tmp -C 1,1 -S AB

use strict;
use warnings;
use File::Basename;
use Getopt::Long;


$| = 1;
my ($afile,$bfile,$columns,$outdir,$outstyle);
GetOptions(
    "afile|A=s" => \$afile,
    "bfile|B=s" => \$bfile,
	"cols|C=s" => \$columns,
	"outdir|O=s" => \$outdir,
	"outstyle|S=s" => \$outstyle,
);


    open A,"< $afile" or die"$!";
    open B,"< $bfile" or die"$!";
	my $ah = <A>;
	$ah =~ s/\s+$//;
	my $bh = <B>;
	$bh =~ s/\s+$//;
	my %afiles = ();
	my @cols = split(/,/,$columns);
	while (<A>) {
	    s/\s+$//;
		my @tmp = split/\s+/;
		$afiles{$tmp[$cols[0]-1]} = $_;
	}
	close A;
	my %bfiles = ();
	while (<B>) {
	    s/\s+$//;
		my @tmp = split/\s+/;
		$bfiles{$tmp[$cols[1]-1]} = $_;
	}
	close B;
	my $afn = basename($afile);
	my $bfn = basename($bfile);
	my ($aname,$suf1) = split(/\./,$afn);
	my ($bname,$suf2) = split(/\./,$bfn);
	my $a_outfile = $aname."_specific.txt";
	my $b_outfile = $bname."_specific.txt";
	my $ab_outfile = $aname."_".$bname."_overlap.txt";
	#open OA,"> $outdir/$a_outfile" or die"$!";
	#open OB,"> $outdir/$b_outfile" or die"$!";
	open OAB,"> $outdir/$ab_outfile" or die"$!";
	#print OA "$ah\n";
    #print OB "$bh\n";
        if ($outstyle eq 'A') {
	    print OAB "$ah\n";
	} elsif ($outstyle eq 'B') {
	    print OAB "$bh\n";
	} elsif ($outstyle eq 'AB') {
	    print OAB "$ah\t$bh\n";
	} else {
	    die"Input the right outstyle(A B or AB)!\n";
	}
	
	for my $a (keys %afiles) {
	    #print $a,"\n";
	    if (defined($bfiles{$a})) {
		    if ($outstyle eq 'A') {
			    print OAB "$afiles{$a}\n";
			} elsif ($outstyle eq 'B') {
			    print OAB "$bfiles{$a}\n";
			} elsif ($outstyle eq 'AB') {
			    print OAB "$afiles{$a}\t$bfiles{$a}\n";
				
			}
		} #else {
		  #  print OA "$afiles{$a}\n";
		#}
	}
	#for my $b (keys %bfiles) {
	#    if (!defined($afiles{$b})) {
	#	   print OB "$bfiles{$b}\n"; 
	#	}
	#}
        close OAB;
        #close OA;
        #close OB;
     print "$outdir$ab_outfile";
     print "$bfile";
open DD,"< $outdir/$ab_outfile" or die"$!";
my $line=readline(DD);
my @data=();
while(<DD>){
chomp;
my @lines = split /\t/;
#print $#lines;
$data[$_] += $lines[$_] for 6..$#lines;#
}
close DD;
my $ab_outfile_total = $bname."_total.txt";
open DA, ">","$outdir/$ab_outfile_total" or die"$!";
print DA "$bh\n";
print DA "Total_junc_ann","\t";
foreach(@data[6..$#data]){
 print DA $_,"\t";
}
close DA;
#print "@data\n";
my $ab_outfile_norm = $bname."_norm.txt";
open FF, ">","$outdir/$ab_outfile_norm" or die"$!";#out put file and path
open AG,"< $bfile" or die"$!";
$line=readline(AG);
print FF join("\t",$line);
while(<AG>){
chomp;
my @lines = split /\t/;
print FF $lines[0],"\t";
foreach (1..$#lines)
{
$lines[$_]=$lines[$_]*10000000/$data[$_+5]; 
print FF $lines[$_],"\t";
}
print FF "\n";
}
close FF;
close AG;  



