#!/bin/bash

out_dir=$1;
filename=$2;
gtf_dir=$3;



cat ${out_dir}/${filename} | awk '{print $1}'|cut -f1 |sed 's/[_]/\t/g' |awk '{ print $1,$2,$3,$1"_"$2"_"$3"_"$4,"0",$4}' OFS="\t"| sort -k1,1 -k2,2n -k3,3n  > ${out_dir}/inter.bed
sed -i '$d' ${out_dir}/inter.bed
bedtools intersect -a ${gtf_dir}/genecode.sort.exon.bed -b ${out_dir}/inter.bed -f 1.0 -wo >${out_dir}/inter.anno
