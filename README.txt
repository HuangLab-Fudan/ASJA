
ASJA: a program for Assembling Splice Junctions Analysis
--------------------------------------------

What is the ASJA
----------------

RNA splicing may generate different kinds of splice junctions, such as linear, back-splice and fusion junctions. Only a limited number of programs are available for detection and quantification of splice junctions. 
Here, we present Assembling Splice Junctions Analysis (ASJA), a software package that identifies and characterizes all splice junctions from high-throughput RNA sequencing (RNA-seq) data. ASJA processes assembled transcripts and chimeric alignments from the STAR aligner and S tringTie assembler. 
ASJA provides the unique position and normalized expression level of each junction. Annotations and integrative analysis of the junctions enable additional filtering. It is also appropriate for the identification of novel junctions.
Implementation and Dependencies
-------------------------------

ASJA was developed with perl (v5) and shell (bash) language. Before running the program, it is necessary to check or download perl packages as follow:
*File::Basename;
*Getopt::Long;
*List::Util qw/min sum max/;

Moreover, ASJA works based on the STAR and StringTie fearturecount, so these tools also should be installed and their pathway should be added in ~/.bashrc
* STAR (version <= 2.5)
* StringTie (version <= 1.2.3)
* featureCounts (version >= 1.5.0)
* sambamba (version >=0.6.6)
ASJA Installation
------------
Download the packages and then unzip it in Linux (CentOS or Ubuntu) 
Documentation
-------------

This chapter provides detailed commands arguments and description of output. the commands are labeled after ‘usage’

Files Needed:
------------
1.	Human genome sequence (hg38.fasta) and GTF File (we recommend GENCODE, and the program will report an error if you use GTF from UCSC) are used to generate STAR index.
2.	Raw data of RNA-seq (fasta.gz)

Commands and arguments
--------------------------
*	Note: the absolute pathway is necessary to perform scripts 
--------------------------------------------------------------------------------------------------------------------------------------------------------------
1, Mapping of RNA-seq data
usage: perl runSTAR.pl [OPTIONS] 
The arguments of runSTAR.pl are as followings and if you want to work with single-read ,please see more detail of STAR on https://github.com/alexdobin/STAR:

	-f1 <FASTA1>  
               Using Illumina paired-end reads, and the name of read1 has to be supplied.
	-f2 <FASTA2>  
               Using Illumina paired-end reads, and the name of read2 has to be supplied.
	-fq_dir <fastq dir> 
               Specifies path to files containing the sequences to be mapped
	-G <path_and_gtf> 
                Specifies the path to the file with annotated transcripts in the standard GTF format.
	-GA <genomeFastaFiles> 
                Specified one or more FASTA files with the genome reference sequences.
	-O <outdir>   
                Specifies path to the directory (henceforth called "genome directory" where the alignment results are stored.)
	-pass 
                Running STAR in the 2-pass alignment mode
	-index
                Generating genome index of STAR with default settings
	-SI_dir < genome index dir>  
                specifies path to the genome directory where genome indexes where generated
	-I <path>  
                Specifies path to the directory where the ASJA installation 
	-S <sample>   
                Name of sample


### Generating genome indexes ##
	usage: perl runSTAR.pl -I path/to/ASJA -index -SI_dir path/to/star_index -G path/to/genecode.annoataion.gtf -GA path/to/GRCh38.primary_assembly.genome.fa
### running STAR in the 2-pass mode [Kahles et al., 2018, Cancer Cell 34, 1–14] ###
	usage:  perl runSTAR.pl -I path/to/ASJA -pass -SI_dir /path/to/star_index -f1 R2.fq.gz -f2 R1.fq.gz -fq_dir path/to/fastq -GA path/to/GRCh38.primary_assembly.genome.fa -O path/to/out_dir -S sample_name
Output:  sample_mapped_reads.bam 
		 Chimeric.out.junction 
		 SJ.out.tab
--------------------------------------------------------------------------------------------------------------------------------------------------------------

2, the extraction and processing of junctions
*	We provide step-by-step processing (ASJA.pl filtering.pl integration.pl) and quick processing(ASJA-all.pl) program to obtain junctions. However, preparing file for annotation only be implemented with ASJA.pl -setup, and generating transcripts for linear junction only be implemented with StringTie. 
****** step-by-step processing ******
usage: perl ASJA.pl [options]
The arguments of ASJA.pl are as followings:
	-I <ASJA dir>  
                 Specifies path to the directory where the ASJA installation
	-G < path_and_gtf >     
                 Specifies the path to the file with annotated transcripts in the standard GTF format.
	-setup           
                 Preparing reference file for annotation junctions
	-linear
                 Extraction linear junctions
	-backsplicing
                 Extraction back splicing junctions
	-fusion
                 Extraction fusion junctions
	-CI < alignment dir>   
                Specified path with the alignment result of STAR
	-SI <path_and_file >  
                Name(s) (with path) of the files containing generated transcript by StringTie.
				The path is also an out_dir
	-ann
                Annotation for junctions
	-ratio
                Calculation ratio

****** The mapped reads were further used to obtain transcripts by StringTie with reference-based transcriptome assembly. please see http://ccb.jhu.edu/software/stringtie/ ******
	usage: stringtie input_mapped_reads.bam -f 0.1 -o path/to/stringtie_assembly.gtf -p 4 -G path/to/gencode.v29.annotation.gtf 

###    The process of preparing file for annotation junctions.  ###
Usage: perl ASJA.pl -I /path/to/ASJA -G path/to/ref/gencode.v29.annotation.gtf -setup

## The extraction of liner junction form stringtie_assembly   ##
Usage: perl ASJA.pl -I path/to/ASJA -linear -G path/to/gencode.v29.annotation.gtf -SI path/to/example/assembly/input/stringtie_assembly.gtf -CI path/to/example/alignment/input -ann -ratio
    
## The extraction of back splicing junction form Chimeric.out.junction   ##
usage: perl ASJA.pl -I path/to/ASJA -backsplicing -G path/to/gencode.v29.annotation.gtf -SI path/to/example/assembly/input/stringtie_assembly.gtf -CI path/to/example/alignment/input -ann -ratio
	
## The extraction of extraction fusion junction form Chimeric.out.junction   ##
usage: perl ASJA.pl -I path/to/ASJA -fusion -G path/to/gencode.v29.annotation.gtf -SI path/to/example/assembly/input/stringtie_assembly.gtf -CI path/to/example/alignment/input -ann -ratio
		
usage: perl filtering.pl [options]
The arguments of filtering.pl are as followings:
	-read <1>
               Set threshold for filtration based on counts of junction reads (optional: e.g. 1)
	-ratio<0.01>
               Set threshold for filtration based on ratio (linear weight ratio/back splicing ratio /fused ratio) of junction (optional: e.g. 0.01)
	-linear
               Filtration of linear junctions
	-backsplicing
               Filtration of back splicing junctions
	-fusion
               Filtration of fusion junctions
	-IN<input file>
               Name(s) (with path) of the files for filtration
	-O<output file>
               Name(s) (with path) of the files for result

## Generating junctions with high-confidence ##
usage: perl filtering.pl -read 1 -ratio 0.08 -linear -IN path/to/Linear.txt -O path/to/F_linear.txt

*	NOTE: For any kind of junction, there should be a threshold to get a high-confidence junction.
          For example, we believe that the screening criteria for high-confidence liner junctions should satisfy the condition that ratio is greater than 0.01 and the number of reads are greater than 1.
	  	  
###   The integration of three types of junctions ###
usage：perl integration.pl -A liner.txt -B circRNA.txt -C fusion.txt -O all.txt
*	Note: These junctions need to be annotated
****** quick processing*******
usage: perl ASJA-all.pl [options]
	-I <dir ASJA>  
             Specifies path to the directory where the ASJA installation
	-G <path_and_gtf>     
             Specifies the path to the file with annotated transcripts in the standard GTF format.
	-CI < dir alignment >           
             Specified path with the alignment result of STAR.
	-SI <path_and_file >  
             Name(s) (with path) of the files containing generated transcript by StringTie
	-O<outdir>
            Specifies path to the directory where the results are stored.

###Quickly get three types of junctions using default parameters ###	
Usage: perl ASJA-all.pl -I /path/to/ASJA -G path/to/gencode.v29.annotation.gtf -CI /path/to/example/alignment/input-SI path/to/example/assembly/input/stringtie_assembly.gtf  -O path/to/result
--------------------------------------------------------------------------------------------------------------------------------------------------------------
3.Other programs
### The read counts of gene level can be calculated by featureCounts. Please see http://subread.sourceforge.net/ ###
	usage: featureCounts -p -T 6 -a genecode.annoataion.gtf -o path/to/featurecount.txt sample_mapped_reads.bam

### the calculation of TPM from featureCounts ###
	usage: perl TPM.pl -A featurecount -B featurecount.summary -O TPM.txt
--------------------------------------------------------------------------------------------------------------------------------------------------------------
The description of Output files generated by ASJA

Linear junction primary format
*	junctions: A unique identifier for a linear junction 
*	CPT: The expression of junction with custom formal (CPT).
*	read: The read count of junction that SJ.out.tab matched.
*	transID: The transcript_id in the reference annotation that the instance matched.
*	geneID: The gene_id in the reference annotation that the instance matched.
*	gene: The gene_name in the reference annotation that the instance matched.
*	type: The gene_type in the reference annotation that the instance matched.
*	Weight ratio: the weight of junction in annotated gene.

Back splicing junction primary format
*	circID: A unique identifier for a back splicing junction 
*	read: the sum of GT_AG_read and CT_AC_read.
*	GT_AG_read: The read count of back splicing that junction type=1(STAR manual) matched.
*	CT_AC_read: The read count of back splicing that junction type=2(STAR manual) matched.
*	left_backratio: 5’ratio of circRNA.
*	right_backratio: 3’ratio of circRNA.
*	annotation: the annotation of circRNA, including gene_id;trans_id;gene_type; gene_name
*	length_exon: the length of exon.
*	pos_exon: the position of exon

Fusion junction primary format
*	fusionID: A unique identifier for a fusion junction
*	read: the sum of GT_AG_read and CT_AC_read.
*	GT_AG_read: The read count of back splicing that junction type=1(STAR manual) matched.
*	CT_AC_read: The read count of back splicing that junction type=2(STAR manual) matched.
*	Leftbackratio: the ratio of accepter
*	Rightbackratio: the ratio of donor
*	left_type: the type of annotation in accepter
*	leftann: the annotation of accepter, including gene_id;transcript_id;gene_type;gene_name;exon_number
*	right_type: the type of annotation in donor
*	rightann: the annotation of accepter, including gene_id;transcript_id;gene_type;gene_name;exon_number
   
An integration output:
*	Gene_name: Gene symbol
*	Linear junctions: A unique identifier for a linear junction
*	circRNA: A unique identifier for circRNA related to linear junction and gene, separate the two circRNAs with a semicolon
*	fusion: A unique identifier for fusion related to linear junction and gene, separate the two fusions with a semicolon
