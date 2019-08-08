#!/usr/bin/perl
#usage: perl intersectionAll.pl -A <junctions> -B <genecode> -O <outdir> -C 1,1 -S AB
#carefull the input sort 
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

if (defined($afile) && defined($bfile) && defined($outdir) && defined($outstyle)) {
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
	my %all;
	while (<B>) {
	    s/\s+$//;
		my @tmp = split/\t/;
		$bfiles{$tmp[$cols[1]-1]} = $_;
		#afile id wheather exists in bfile and sort into all
		if(exists $afiles{$tmp[$cols[1]-1]}){
			
			if(exists $all{$tmp[$cols[1]-1]}){
				my $old=$all{$tmp[$cols[1]-1]};
				my @oldarr=split/\t/,$old;
				
				my $newtrans=join(",",$tmp[1],$oldarr[1]);
				my $newgeneid=join(",",$tmp[2],$oldarr[2]);
				my $newgene=join(",",$tmp[3],$oldarr[3]);
				my $newtype=join(",",$tmp[4],$oldarr[4]);
				
				my $new=join("\t",$tmp[0],$newtrans,$newgeneid,$newgene,$newtype);
				$all{$tmp[$cols[1]-1]}=$new;
			}
			else{
				$all{$tmp[$cols[1]-1]}=$_;
			}
		}

		
	}
	close B;
	my $afn = basename($afile);
	my $bfn = basename($bfile);
	my ($aname,$suf1) = split(/\./,$afn);
	my ($bname,$suf2) = split(/\./,$bfn);
	my $a_outfile = $aname."_specific.txt";
	my $b_outfile = $bname."_specific.txt";
	my $ab_outfile = "junction_SJ_gencode_overlap.txt";
	open OA,"> $outdir/$a_outfile" or die"$!";
	open OB,"> $outdir/$b_outfile" or die"$!";
	open OAB,"> $outdir/$ab_outfile" or die"$!";
	print OA "$ah\n";
        print OB "$bh\n";
        if ($outstyle eq 'A') {
	    print OAB "$ah\n";
	} elsif ($outstyle eq 'B') {
	    print OAB "$bh\n";
	} elsif ($outstyle eq 'AB') {
	    print OAB "$ah\t$bh\n";
	} else {
	    die"Input the right outstyle(A B or AB)!\n";
	}
	my %junction;
	for my $a (keys %afiles) {
	    if (defined($bfiles{$a})) {
		    if ($outstyle eq 'A') {
			    print OAB "$afiles{$a}\n";
			} elsif ($outstyle eq 'B') {
			    print OAB "$bfiles{$a}\n";
			} elsif ($outstyle eq 'AB') {
				##
				print OAB "$afiles{$a}\t";
				my $item=$all{$a};
				my @itemarr=split/\t/,$item;
				foreach(@itemarr){
				my @array=split/,/,$_;
				my %h;
				my @uniq_times = grep { ++$h{ $_ } < 2; } @array;
				print OAB join(";",@uniq_times),"\t";
				}

			    print OAB "\n";
			}
		} else {
		    print OA "$afiles{$a}\n";
		}
	}
	for my $b (keys %bfiles) {
	    if (!defined($afiles{$b})) {
		   print OB "$bfiles{$b}\n"; 
		}
	}
        close OAB;
        close OA;
        close OB;
	
} else {
    print "Options are missing!\n";
}

