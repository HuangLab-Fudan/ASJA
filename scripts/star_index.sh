#!/usr/bin/bash
index_dir=$1
genomeFasta=$2
gtf=$3
STAR --runThreadN 15 --runMode genomeGenerate --genomeDir ${index_dir} --genomeFastaFiles ${genomeFasta} --sjdbGTFfile ${gtf} --sjdbOverhang 100
