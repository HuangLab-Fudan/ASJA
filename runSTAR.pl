#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use File::Basename;
use Getopt::Long;

### need absoulate pathway
###usage: perl runSTAR.pl -I <indir> -O <outdir> -index
################
#	options:
#	-f1 <FASTA1>  left.fa.gz
#	-f2 <FASTA1>  right.fa.gz
#	-fq_dir <fastq dir>    dir of fastq  
#	-G  <gtf>     genecode.annoataion.gtf
#	-GA <genomeFastaFiles>    path/to/GRCh38.primary_assembly.genome.fa
#	-O <outdir>   outfile dir
#	-pass         run STAR allignemt of two pass
#	-index        create STAR index
#	-SI_dir <STAR index dir>  the dir of STAR index
#	-I <ASAJ dir>  dir of ASAJ 
#	-S <sample>    sample
################
#
my $left_fq;
my $right_fq;
my $gtf;
my $genomeFastaFiles;
my $outdir;
my $dir_star_index;
my $index=0;
my $pass=0;
my $indir;
my $sample;
my $fastq_dir;

&GetOptions ( 
			'left_fq|f1=s' => \$left_fq,
			'right_fq|f2=s' => \$right_fq,
			'gtf|G=s' => \$gtf,
			'genomeFastaFiles|GA=s' => \$genomeFastaFiles,
			'outdir|O=s' => \$outdir,
			'dir_star_index|SI_dir=s' => \$dir_star_index,
			'fastq_dir|fq_dir=s' => \$fastq_dir,
			'indir|I=s' => \$indir,
			'sample|S=s' => \$sample,
			'index' => \$index,
			'pass' => \$pass,

);

### create index or not
	if($index){
		if(defined($dir_star_index) && defined($genomeFastaFiles)&& defined($gtf)){
			my $cmd= "sh $indir/scripts/star_index.sh $dir_star_index $genomeFastaFiles $gtf";
			system("$cmd");
			}
		else{
			print "some variables are not defined please check dir_star_index\tgenomeFastaFiles\tgtf\n";
		}
	
	}
	else{
	print "The STAR genome index is not created using this command\n"
	}
	
	if($pass){
	#print $pass,"\n";
### run STAR or not
		if(defined($dir_star_index) && defined($genomeFastaFiles)&& defined($sample) && defined($fastq_dir)&& defined($outdir) && defined($left_fq)){
			my $cmd = "sh $indir/scripts/two_pass.sh $dir_star_index $genomeFastaFiles $sample $fastq_dir $outdir $left_fq $right_fq";
			system("$cmd");
		}
		else{
			print "some variables are not defined please check dir_star_index\tgenomeFastaFiles\tsample\tfastq_dir\toutdir\n";
			}
	}
	else{
	print "tow pass of STAR is not used\n";
	}


