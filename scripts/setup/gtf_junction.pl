#!/usr/bin/perl
#usage: perl gtf_junctions.pl -G <gtf_file>

use strict;
use warnings;
use File::Basename;
use Getopt::Long;

$| = 1;
my ($gtf,$outfile);
GetOptions(
    "gtf|G=s" => \$gtf,
);

if (defined($gtf)) {
    my ($fn,$fdir,$suf) = fileparse($gtf,'.gtf');
	my $outname = "temp.txt";
	open GTF,"< $gtf" or die"$!";
	open OUT,"> $fdir/$outname" or die"$!";
	print OUT "Junction\tTranscript_id\tGene_id\tGene_name\tGene_type\n";
	my @exon1 = ();
	my $strand = ();
	while (<GTF>) {
	    next if (/^#/);
		s/\s+$//;
		my @tmp = split/\t/;
		if ($tmp[2] eq 'transcript') {
		    @exon1 = ();
			if ($tmp[6] =~ /\./) {
			    $strand = '+';
			} else {
			    $strand = $tmp[6];
			}
		} elsif ($tmp[2] eq 'exon') {
		    if (@exon1 == 0) {
			    push @exon1,@tmp[0,3,4],$strand;
			} elsif (@exon1 != 0) {
				my $junction;
			    if($exon1[3]=~/\+/){
				$junction = $tmp[0].':'.$exon1[2].'|'.$tmp[3].':'.$exon1[3];
				}
				else{
				#$junction = $tmp[0].':'.$exon1[1].'|'.$tmp[4].':'.$exon1[3];
				$junction = $tmp[0].':'.$tmp[4].'|'.$exon1[1].':'.$exon1[3];
				}
				
				$tmp[8] =~ /transcript_id \"(.*?)\";/;
			    my $tid = $1;
			    $tmp[8] =~ /gene_id \"(.*?)\";/;
			    my $gid = $1;
			    $tmp[8] =~ /gene_name \"(.*?)\";/;
			    my $gname = $1;
			    $tmp[8] =~ /gene_type \"(.*?)\";/;
			    my $gtype = $1;
			    print OUT "$junction\t$tid\t$gid\t$gname\t$gtype\n";
				@exon1 = ();
				push @exon1,@tmp[0,3,4],$strand;
			}
		}
	}
	close GTF;
	close OUT;
} else {
    print "Options are missing!\n";
}

