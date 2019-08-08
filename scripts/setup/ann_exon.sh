#!/bin/bash

indir=$1
gtf=$2
outname=$3
outnametmp=${outname}"res"
s5=`perl ${indir} -G ${gtf} -O ${outnametmp}`
echo $s5
tail -n +2 ${outnametmp} |fgrep exon_number | sort -k1,1 -k2,2n -k3,3n > ${outname}
rm -rf ${outnametmp}
echo "setup work has completed "
