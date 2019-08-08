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
###usage: perl ASJA.pl -I <indir> -O <outdir> 
################

#############

#	options 3-5:
#	-I <ASAJ dir>  dir of ASAJ 
#	-CI <dir of alignment>            path/to/alignment/sample
#	-SI <gtf of stringtie result >    path/to/assembly/sample/stringtie_assembly.gtf
#	-G  <gtf>     path/to/genecode.annoataion.gtf
#	-O  <outfile>  path/to/outdir
#	
################
#


my $gtf;
my $filter_read=1;
my $filter_ratio=0.08;
my $Chimeric;
my $bam_dir;
my $stringtie;
my $indir;
my $outfile;

&GetOptions ( 
			'gtf|G=s' => \$gtf,
			'bam_dir|CI=s' => \$bam_dir,
			'stringtie|SI=s' => \$stringtie,
			'indir|I=s' => \$indir,
			'outfile|O=s' => \$outfile,

);
    my $datestring = localtime();
	print "localtime: $datestring\n";
	my @dir=split/\//,$gtf;
	my $gtf_dir=join("/",@dir[0..$#dir-1]);
	#print $gtf_dir,"\n";
	my $outname = $gtf_dir."/"."gencode.v29.annotation_junctions_filtered.txt";
	my $gene_exon=$gtf_dir."/"."genecode.sort.exon.bed";
	if(defined($gtf) and defined($bam_dir) and($stringtie)){
	
	
	my @temp_dir;
	my $liner_dir;
	$Chimeric=join("/",$bam_dir,"Chimeric.out.junction");
	if(defined($stringtie)){
	@temp_dir=split/\//,$stringtie;
	$liner_dir=join("/",@temp_dir[0..$#temp_dir-1]);
	}
	print "sample:",$temp_dir[$#temp_dir-1],"\n";
			 my $out_filter_linear=join("/",$outfile,"filter");
			 my $mk3=`mkdir -p $out_filter_linear`;
		if(defined($indir) && defined($stringtie)){
			print "-----------------------------------------------------------\n";
			print "the extraction of liner junction form stringtie_assembly\n ";
			my $out=join("/",$outfile,"raw/norm");
			print "outdir : ",$out,"\n";
			my $mk=`mkdir -p $out`;
			
			my $cmd="perl $indir/scripts/liner/junctionsMin.pl -I $stringtie";
			system("$cmd");
			### based on annoataion to re-quality

			my $cmd2="perl $indir/scripts/liner/total_norm_v3.pl -A $outname -B $liner_dir/stringtie_assembly_junctions.txt -O $out -C 1,1 -S AB";
			system("$cmd2");

			my $cmd3="perl $indir/scripts/liner/SJout.pl -A $bam_dir/SJ.out.tab -B $outfile/raw/norm/stringtie_assembly_junctions_norm.txt -O $outfile/raw/norm/junction_SJ";
			system("$cmd3");
			my $a1=join("/",$out,"gencode_stringtie_assembly_junctions_overlap.txt");
			my $a2=join("/",$out,"stringtie_assembly_junctions_total.txt");
			my $rm1=`rm $a1`;
			my $rm2=`rm $a2`;
			
			### complete\n
			my $out2=join("/",$out,"ann");
			my $mk2=`mkdir -p $out2`;
			
				print "annoataion :";
				my $cmd4="perl $indir/scripts/liner/annotionAll.pl -A $outfile/raw/norm/junction_SJ -B $outname -C 1,1 -O $outfile/raw/norm/ann -S AB";
				system("$cmd4");
				print "the result is sorted in junction_SJ_gencode_overlap.txt\n";
			
			
				print "weight ratio\n";
				# my $ck=join("/",$out2,"junction_SJ_gencode_overlap.txt");
				# if(-e $ck){
				# }
				# else{
				# my $cmd4="perl $indir/scripts/liner/annotionAll.pl -A $liner_dir/norm/junction_SJ -B $outname -C 1,1 -O $liner_dir/norm/ann -S AB";
				# system("$cmd4");
				# }
				### have gene ann
				my $cmd5="perl $indir/scripts/liner/sort_index.pl -A $outfile/raw/norm/ann/junction_SJ_gencode_overlap.txt -O $outfile/raw/norm/ann/1.txt";
				system("$cmd5");
				### not have
				my $cmd6="perl $indir/scripts/liner/gtf_junction2.pl -G $stringtie -I $outfile/raw/norm/ann/junction_SJ_specific.txt -O $outfile/raw/norm/ann/junction_stringtie.txt";
				system("$cmd6");
				my $cmd7="perl $indir/scripts/liner/sort_index_novel.pl -A $outfile/raw/norm/ann/junction_stringtie.txt -O $outfile/raw/norm/ann/2.txt";
				system("$cmd7");
				my $tp=join("/",$outfile,"raw/norm/ann/Linear.txt");
				my $tmtp=`rm -rf $tp`;
				my $fi=`cat $outfile/raw/norm/ann/1.txt $outfile/raw/norm/ann/2.txt >>$outfile/raw/norm/ann/Linear.txt`;
				
				print "\nthe result is sorted in Linear.txt\n";
				#####
				# my $out_filter_linear=join("/",$liner_dir,"filter");
				# my $mk3=`mkdir -p $out_filter_linear`;
				print "filtering linear junction with default setting is sorted in $out_filter_linear\n";
				my $cmd8="perl $indir/filtering.pl -read 1 -ratio 0.08 -linear -IN $outfile/raw/norm/ann/Linear.txt -O $out_filter_linear/filter_linear.txt";
				system("$cmd8");
		}	
		else{
			print "please check ASJA dir as well as result of stringtie and its dir\n";
		}
		
		

######backsplicing
		
		my $out3=join("/",$outfile,"raw/circ");
		my $mk4=`mkdir -p $out3`;
		print "-----------------------------------------------------------\n";
		print "the extraction of back splicing junction form Chimeric.out.junction\n outdir : $out3\n";
		my $cmd9="perl $indir/scripts/circ/test.pl -A $Chimeric -O $outfile/raw/circ/circ_step1.txt";
		system("$cmd9");
	
			my $ck=join("/",$outfile,"raw/norm/junction_SJ");
			if(-e $ck){
			print "annoataion and back_radio\n";
			
			my $cmd10="perl $indir/scripts/circ/back.pl -A $outfile/raw/circ/circ_step1.txt -B $outfile/raw/norm/junction_SJ -O $outfile/raw/circ/ratio.txt";
			system("$cmd10");
			my $cmd11= "sh $indir/scripts/circ/ann.sh $outfile/raw/circ ratio.txt $gtf_dir";
			system("$cmd11");
			my $cmd12="perl $indir/scripts/circ/circ_exon.pl -A $outfile/raw/circ/inter.anno -O $outfile/raw/circ/inter.anno.result.txt";
			system("$cmd12");
			my $cmd13="perl $indir/scripts/circ/inter.pl -A $outfile/raw/circ/inter.anno.result.txt -B $outfile/raw/circ/ratio.txt -O $outfile/raw/circ/circRNA.txt";
			system("$cmd13");
			print "the extraction of back spliced is complete\n";
			
			print "filtering circ junction with default setting is sorted in $out_filter_linear\n";
			my $cmd14="perl $indir/filtering.pl -read 1 -ratio 0.15 -backsplicing -IN $outfile/raw/circ/circRNA.txt -O $out_filter_linear/filter_circ.txt";
			system("$cmd14");
			}
			else{
			print "Check whether linear junction completes the extraction\n ";
			}
	
		

# # ##### fusion	
	
		
		my $out4=join("/",$outfile,"raw/fusion");
		my $mk5=`mkdir -p $out4`;
		print "-----------------------------------------------------------\n";
		print "the extraction of fusion junction form Chimeric.out.junction\n outdir : $out4\n";
		my $cmd15="perl $indir/scripts/fusion/fristv2.pl -A $Chimeric -O $outfile/raw/fusion/fusion_step1.txt";
		system("$cmd15");
		
			my $ck2=join("/",$outfile,"raw/norm/junction_SJ");
			if(-e $ck2){
			print "annoataion and radio\n";
			my $cmd16="perl $indir/scripts/fusion/back.pl -A $outfile/raw/fusion/fusion_step1.txt -B $outfile/raw/norm/junction_SJ -O $outfile/raw/fusion/fusion_ratio.txt";
			system("$cmd16");
			my $cmd17="perl $indir/scripts/fusion/ann.pl -A ${gtf_dir}/genecode.sort.exon.bed -B $outfile/raw/fusion/fusion_ratio.txt -O $outfile/raw/fusion/Fusion.txt";
			system("$cmd17");
			
			print "filtering fusion junction with default setting is sorted in $out_filter_linear\n";
			my $cmd18="perl $indir/filtering.pl -read 1 -ratio 0.15 -fusion -IN $outfile/raw/fusion/Fusion.txt -O $out_filter_linear/filter_fusion.txt";
			system("$cmd18");
			}
			else{
			print "Check whether linear junction completes the extraction\n ";
			}
		
		
		print "the extraction of fusion is complete\n";
		print "-----------------------------------------------------------\n";
		print "ASJA integrate a file to sorted three types of high confidence junctions and genes\n";
		my $cmd19="perl $indir/integration.pl -A $out_filter_linear/filter_linear.txt -B $out_filter_linear/filter_circ.txt -C $out_filter_linear/filter_fusion.txt -O $out_filter_linear/all.txt";
		system("$cmd19");
		my $enddatestring = localtime();
		print "localtime: $enddatestring\n";
	}
	else{
		print "Options are missing!\n";


}