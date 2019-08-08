#!/usr/bin/bash
GDC_ref=$1
genomeFasta=$2
samples=$3
fastq_dir=$4
bam_dir=$5
Read1=$6
Read2=$7
 Bam_out='_mapped_reads.bam'
 X1='_x1'
 X1SJ='_x1SJ.out.tab'
 Index2='_index2'

for s in ${samples}
do
mkdir -p ${bam_dir}/$s
cd ${bam_dir}/$s
STAR --genomeDir ${GDC_ref} --readFilesIn ${fastq_dir}/${Read1} ${fastq_dir}/${Read2} --runThreadN 15 --outFilterMultimapScoreRange 1 --outFilterMultimapNmax 20 --outFilterMismatchNmax 10 --alignIntronMax 500000 --alignMatesGapMax 1000000 --sjdbScore 2 --alignSJDBoverhangMin 1 --genomeLoad NoSharedMemory --outFilterMatchNminOverLread 0.33 --outFilterScoreMinOverLread 0.33 --sjdbOverhang 100 --outSAMstrandField intronMotif --outSAMtype None --outSAMmode None --readFilesCommand zcat --outFileNamePrefix ${bam_dir}/$s/$s${X1}
cd ${bam_dir}/$s
mkdir -p ${bam_dir}/$s/$s${Index2}
STAR --runMode genomeGenerate --genomeDir ${bam_dir}/$s/$s${Index2} --genomeFastaFiles ${genomeFasta} --sjdbOverhang 100 --runThreadN 15 --sjdbFileChrStartEnd ${bam_dir}/$s/$s${X1SJ} 
cd ${bam_dir}/$s
STAR --genomeDir ${bam_dir}/$s/$s${Index2} --readFilesIn ${fastq_dir}/${Read1} ${fastq_dir}/${Read2} --runThreadN 15 --outFilterMultimapScoreRange 1 --outFilterMultimapNmax 20 --outFilterMismatchNmax 10 --alignIntronMax 500000 --alignMatesGapMax 1000000 --sjdbScore 2 --alignSJDBoverhangMin 1 --genomeLoad NoSharedMemory --limitBAMsortRAM 70000000000 --outFilterMatchNminOverLread 0.33 --outFilterScoreMinOverLread 0.33 --sjdbOverhang 100 --outSAMstrandField intronMotif --outSAMattributes NH HI NM MD AS XS --outSAMunmapped Within --outSAMtype BAM SortedByCoordinate --outSAMheaderHD @HD VN:1.4 Sergey --readFilesCommand zcat --chimOutType WithinBAM  --chimSegmentMin 20
mv ${bam_dir}/$s/Aligned.sortedByCoord.out.bam ${bam_dir}/$s/$s${Bam_out}
sambamba index ${bam_dir}/$s/$s${Bam_out}
rm -rf ${bam_dir}/$s/$s${Index2}
done
