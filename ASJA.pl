#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use File::Basename;
use Getopt::Long;

### need absoulate pathway
### 1.produce gencode.annotation_junctions.txt and filtter it
### 2.produce genecode.sort.exon.bed for anntation circRNA and fusion
### 3.liner junction and annoataion and ratio
### 4.backsplicing junction and annoataion and ratio
### 5.fusion junction and annoataion and ratio
###usage: perl ASAJ.pl -I <indir> -O <outdir> 
################
#	options 1-2:
#	-I <ASAJ dir>  dir of ASAJ 
#	-G  <gtf>      path/to/genecode.annoataion.gtf
#	-O <outfile>   path/to/outfile
#	-setup            setup reference file about junctions
#	
#############

#	options 3-5:
#	-linear            liner junction
#	-backsplicing            backsplicing junction
#	-fusion            fusion junction
#	-CI <dir of alignment>            path/to/alignment
#	-SI <gtf of stringtie result >    path/to/stringtie_assembly.gtf
#	-ann                              annotate or not
#	-ratio                            calculate ratio or not 
#	-filter_read <1>                 delete junction below 1 read
#	-filter_ratio <0.01>             delete junction below 0.01 ratio
#	
#	
################
#


my $gtf;
my $outdir;
my $index=0;
my $indir;
my $sample;
my $setup=0;
my $liner=0;
my $backsplicing=0;
my $fusion=0;
my $ann=0;
my $ratio=0;
my $filter_read=0;
my $filter_ratio=0;
my $Chimeric;
my $bam_dir;
my $stringtie;



&GetOptions ( 
			'gtf|G=s' => \$gtf,
			'outdir|O=s' => \$outdir,
			'indir|I=s' => \$indir,
			'sample|S=s' => \$sample,
			'setup' => \$setup,
			'linear' => \$liner,
			'backsplicing' => \$backsplicing,
			'fusion' => \$fusion,
			'ann' => \$ann,
			'ratio' => \$ratio,
			'bam_dir|CI=s' => \$bam_dir,
			'stringtie|SI=s' => \$stringtie,
			

);
	my @dir=split/\//,$gtf;
	my $gtf_dir=join("/",@dir[0..$#dir-1]);
	#print $gtf_dir,"\n";
	my $outname = $gtf_dir."/"."gencode.v29.annotation_junctions_filtered.txt";
	my $gene_exon=$gtf_dir."/"."genecode.sort.exon.bed";
	if($setup){
		if(defined($indir) && defined($gtf)){
			print "------------------------------------------------\n";
			print "the progress of setup reference file is going on";
			my $cmd= "perl $indir/scripts/setup/gtf_junction.pl -G $gtf";
			system("$cmd");
			my $in=$gtf_dir."/"."temp.txt";	
			my $cmd2="perl $indir/scripts/setup/check.pl -A $in -O $outname";
			system("$cmd2");
			my $rm=`rm $in`;
			my $cmd3="sh $indir/scripts/setup/ann_exon.sh $indir/scripts/setup/genecode_exon.pl $gtf $gene_exon";
			system("$cmd3");
			}
		else{
			print "please check dir of ASAJ and gtf.\n";
		}
	}
	else{
		print "setup reference file has complete, junctions will be extracted.\n";
	
	
	my @temp_dir;
	my $liner_dir;
	$Chimeric=join("/",$bam_dir,"Chimeric.out.junction");
	if(defined($stringtie)){
	@temp_dir=split/\//,$stringtie;
	$liner_dir=join("/",@temp_dir[0..$#temp_dir-1]);
	}
	print "sample:",$temp_dir[$#temp_dir-1],"\n";
	if($liner){
		if(defined($indir) && defined($stringtie)){
			print "------------------------------------------------\n";
			print "the extraction of liner junction form stringtie_assembly\n ";
			my $cmd="perl $indir/scripts/liner/junctionsMin.pl -I $stringtie";
			system("$cmd");
			### based on annoataion to re-quality
			my $out=join("/",$liner_dir,"norm");
			print "outdir:",$out,"\n";
			my $mk=`mkdir -p $out`;
			my $cmd2="perl $indir/scripts/liner/total_norm_v3.pl -A $outname -B $liner_dir/stringtie_assembly_junctions.txt -O $out -C 1,1 -S AB";
			system("$cmd2");

			my $cmd3="perl $indir/scripts/liner/SJout.pl -A $bam_dir/SJ.out.tab -B $liner_dir/norm/stringtie_assembly_junctions_norm.txt -O $liner_dir/norm/junction_SJ";
			system("$cmd3");
			my $a1=join("/",$out,"gencode_stringtie_assembly_junctions_overlap.txt");
			#my $a2=join("/".$out,"stringtie_assembly_junctions_total.txt");
			my $rm1=`rm $a1`;
			#my $rm2=`rm $a2`;
			
			### The process of extracting junction is ended
			my $out2=join("/",$out,"ann");
			my $mk2=`mkdir -p $out2`;
			if($ann){
				print "annoataion\n";
				my $cmd4="perl $indir/scripts/liner/annotionAll.pl -A $liner_dir/norm/junction_SJ -B $outname -C 1,1 -O $liner_dir/norm/ann -S AB";
				system("$cmd4");
				print "the result is sorted in junction_SJ_gencode_overlap.txt\n";
			}
			if($ratio){
				print "ratio\n";
				my $ck=join("/",$out2,"junction_SJ_gencode_overlap.txt");
				if(-e $ck){
				}
				else{
				my $cmd4="perl $indir/scripts/liner/annotionAll.pl -A $liner_dir/norm/junction_SJ -B $outname -C 1,1 -O $liner_dir/norm/ann -S AB";
				system("$cmd4");
				}
				### have gene ann
				my $cmd5="perl $indir/scripts/liner/sort_index.pl -A $liner_dir/norm/ann/junction_SJ_gencode_overlap.txt -O $liner_dir/norm/ann/1.txt";
				system("$cmd5");
				### not have
				my $cmd6="perl $indir/scripts/liner/gtf_junction2.pl -G $stringtie -I $liner_dir/norm/ann/junction_SJ_specific.txt -O $liner_dir/norm/ann/junction_stringtie.txt";
				system("$cmd6");
				my $cmd7="perl $indir/scripts/liner/sort_index_novel.pl -A $liner_dir/norm/ann/junction_stringtie.txt -O $liner_dir/norm/ann/2.txt";
				system("$cmd7");
				my $tp=join("/",$liner_dir,"norm/ann/Liner.txt");
				my $tmtp=`rm -rf $tp`;
				my $fi=`cat $liner_dir/norm/ann/1.txt $liner_dir/norm/ann/2.txt >>$liner_dir/norm/ann/Liner.txt`;
				print "\tthe result is sorted in Liner.txt\n";
			}
		}	
		else{
			print "please check ASAJ dir as well as result of stringtie and its dir\n";
		}
		
		
	}
	else{
	print "**The extraction of linear junctions is not performed in this process**\n";
	}
######backsplicing
	if($backsplicing && defined($bam_dir)){
		print "------------------------------------------------\n";
		print "the extraction of back splicing junction form Chimeric.out.junction\n";
		my $out3=join("/",$liner_dir,"circ");
		my $mk3=`mkdir -p $out3`;
		print "outdir:",$out3,"\n";
		my $cmd="perl $indir/scripts/circ/test.pl -A $Chimeric -O $liner_dir/circ/step1.txt";
		system("$cmd");
		if($ann && $ratio){
			my $ck=join("/",$liner_dir,"norm/junction_SJ");
			if(-e $ck){
			print "annoataion and radio\n";
			print "$liner_dir/circ/ratio.txt\n";
			my $cmd2="perl $indir/scripts/circ/back.pl -A $liner_dir/circ/step1.txt -B $liner_dir/norm/junction_SJ -O $liner_dir/circ/ratio.txt";
			system("$cmd2");
			my $cmd= "sh $indir/scripts/circ/ann.sh $liner_dir/circ ratio.txt $gtf_dir";
			system("$cmd");
			my $cmd3="perl $indir/scripts/circ/circ_exon.pl -A $liner_dir/circ/inter.anno -O $liner_dir/circ/inter.anno.result.txt";
			system("$cmd3");
			my $cmd4="perl $indir/scripts/circ/inter.pl -A $liner_dir/circ/inter.anno.result.txt -B $liner_dir/circ/ratio.txt -O $liner_dir/circ/circRNA.txt";
			system("$cmd4");
			}
			else{
			print "Check whether linear junction completes the extraction\n ";
			}
		}
		elsif($ann){
			print "annoataion\n";
			my $cmd= "sh $indir/scripts/circ/ann.sh $liner_dir/circ step1.txt $gtf_dir";
			system("$cmd");
			my $cmd3="perl $indir/scripts/circ/circ_exon.pl -A $liner_dir/circ/inter.anno -O $liner_dir/circ/inter.anno.result.txt";
			system("$cmd3");
			my $cmd4="perl $indir/scripts/circ/inter.pl -A $liner_dir/circ/inter.anno.result.txt -B $liner_dir/circ/step1.txt -O $liner_dir/circ/circRNA.txt";
			system("$cmd4");
		}
		elsif($ratio){
			print "ratio\n";
			my $ck=join("/",$liner_dir,"norm/junction_SJ");
			if(-e $ck){
			print "$liner_dir/circ/ratio.txt\n";
			my $cmd2="perl $indir/scripts/circ/back.pl -A $liner_dir/circ/step1.txt -B $liner_dir/norm/junction_SJ -O $liner_dir/circ/ratio.txt";
			system("$cmd2");
			}
			else{
			print "Check whether linear junction completes the extraction\n ";
			}
			
		}
		print "the extraction of back spliced is complete\n";
	}
	else{
	print "**The extraction of back splicing is not performed in this process**\n";
	}
# ##### fusion	
	if($fusion && defined($bam_dir)){
		print "------------------------------------------------\n";
		print "the extraction of extraction fusion junction form Chimeric.out.junction\n";
		my $out4=join("/",$liner_dir,"fusion");
		my $mk=`mkdir -p $out4`;
		print "outdir:",$out4,"\n";
		my $cmd="perl $indir/scripts/fusion/fristv2.pl -A $Chimeric -O $liner_dir/fusion/step1.txt";
		system("$cmd");
		if($ratio && $ann==0){
			my $ck=join("/",$liner_dir,"norm/junction_SJ");
			if(-e $ck){
			print "radio\n";
			my $cmd2="perl $indir/scripts/fusion/back.pl -A $liner_dir/fusion/step1.txt -B $liner_dir/norm/junction_SJ -O $liner_dir/fusion/frist_ratio.txt";
			system("$cmd2");
			}
			else{
			print "Check whether linear junction completes the extraction\n ";
			next;
			}
		}
		if($ann && $ratio==0){
			print "annoataion\n";
			my $cmd3="perl $indir/scripts/fusion/ann.pl -A ${gtf_dir}/genecode.sort.exon.bed -B $liner_dir/fusion/step1.txt -O $liner_dir/fusion/Fusion.txt";
			system("$cmd3");	
		
		}
		if($ann && $ratio){
			my $ck=join("/",$liner_dir,"norm/junction_SJ");
			if(-e $ck){
			print "annoataion and radio\n";
			my $cmd2="perl $indir/scripts/fusion/back.pl -A $liner_dir/fusion/step1.txt -B $liner_dir/norm/junction_SJ -O $liner_dir/fusion/frist_ratio.txt";
			system("$cmd2");
			my $cmd3="perl $indir/scripts/fusion/ann.pl -A ${gtf_dir}/genecode.sort.exon.bed -B $liner_dir/fusion/frist_ratio.txt -O $liner_dir/fusion/Fusion.txt";
			system("$cmd3");
			}
			else{
			print "Check whether linear junction completes the extraction\n ";
			}
		
		}
		print "the extraction of fusion is complete\n";
	}
	else{
	print "**The extraction of fusion is not performed in this process**\n";
	}

}