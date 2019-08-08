#!/usr/bin/perl
#usage: perl junctions.pl -I /XXX
use strict;
use warnings;
use File::Basename;
use List::Util qw/min sum/;
use Getopt::Long;

my $indir;
my $outdir;
GetOptions(
    "indir|I=s" => \$indir,
	"outdir|O=s" => \$outdir
);

if (defined($indir)) {
        my @dir=split/\//,$indir;
		my $infile_dir=join("/",@dir[0..$#dir-1]);
		open IN,"< $indir" or die"$!";
		open OUT,"> $infile_dir/stringtie_assembly_junctions.txt" or die"$!";
		print OUT "Junction\tCPT\n";
		<IN>;
		<IN>;
		my $ref = {};
		my @exon1 = ();
		my $strand = '';
		while (<IN>) {
		    s/\s+$//;
			
			my @tmp = split/\t/;
			next if($tmp[0]=~/_/);
			next if($tmp[0]!~/^chr/i);
			next if($tmp[3]=~/chrM/i);
			if ($tmp[2] eq 'transcript') {
			    @exon1 = ();
				if ($tmp[6] =~ /\./) {
				    $strand = '+';
				} else {
				    $strand = $tmp[6];
				}
			} elsif ($tmp[2] eq 'exon') {
			    $tmp[8] =~ /cov \"(.*?)\";/;
				my $e_cov = $1;
				if (@exon1 == 0) {
					push @exon1,@tmp[0,3,4],$strand,$e_cov;
				} elsif (@exon1 != 0) {
				    my $junction = $tmp[0].':'.$exon1[2].'|'.$tmp[3].':'.$exon1[3];
					push @{$ref->{$junction}->{'e1'}},$exon1[4];
					push @{$ref->{$junction}->{'e2'}},$e_cov;
					@exon1 = ();
					push @exon1,@tmp[0,3,4],$strand,$e_cov;
				}
			}
		}
		close IN;
		for my $j (keys %{$ref}) {
		    my @up_values = @{$ref->{$j}->{'e1'}};
			my @down_values = @{$ref->{$j}->{'e2'}};
			#my $j_values = (sum(@up_values)+sum(@down_values))/2;
			my $j_values = min(sum(@up_values),sum(@down_values));
			if($j_values>0.0001){
			print OUT "$j\t$j_values\n";
			}
			
		}
		close OUT;
	
} else {
    print "Options are missing!\n";
}

